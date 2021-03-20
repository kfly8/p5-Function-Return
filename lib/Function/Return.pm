package Function::Return;

use v5.14.0;
use warnings;

our $VERSION = "0.09";

use Attribute::Handlers;
use B::Hooks::EndOfScope;

use Scope::Upper ();
use Sub::Meta;
use Sub::Meta::Library;
use Sub::Meta::Creator;
use Sub::Meta::Finder::FunctionParameters;
use namespace::autoclean;

my @RETURN_ARGS;
my %NO_CHECK;

sub import {
    my $class = shift;
    my %args = @_;

    my $pkg = $args{pkg} ? $args{pkg} : scalar caller;
    $NO_CHECK{$pkg} = !!$args{no_check} if exists $args{no_check};

    {
        # allow importing package to use attribute
        no strict qw(refs);
        my $MODIFY_CODE_ATTRIBUTES = \&Attribute::Handlers::UNIVERSAL::MODIFY_CODE_ATTRIBUTES;
        *{"${pkg}::MODIFY_CODE_ATTRIBUTES"} = $MODIFY_CODE_ATTRIBUTES;
        *{"${pkg}::_ATTR_CODE_Return"} = $class->can('Return');
    }

    #
    # How to install meta information
    #   1. At the BEGIN phase, write down the meta information via the `Return` attribute.
    #   2. At the compile phase, install the meta information in bulk via this `import` subroutine.
    #
    # In short,
    #   once Function::Return#import is compiled, the meta-information can be retrieved.
    #
    # The Reason Why?
    #
    #   First NG CASE:
    #     At the **CHECK** phase, write down the meta information via the Return attribute. (Attribute::Handler's default case)
    #     Then, cannot support lazy load.
    #     Ref: case_lazy_load.t
    #
    #   Second NG CASE:
    #     At the compile phase, install the meta information in bulk via this **Return** attribute.
    #     Then, unable to retrieve meta information for Function::Return from places that are compiled before the Return attribute.
    #     Ref: case_load_and_get_meta.t
    #
    on_scope_end {
        while (my $args = shift @RETURN_ARGS) {
            my ($pkg, $sub, $types) = @$args;
            my $no_check = exists $NO_CHECK{$pkg} ? $NO_CHECK{$pkg} : ($ENV{FUNCTION_RETURN_NO_CHECK}//0);

            if ($no_check) {
                $class->_register_submeta($pkg, $sub, $types);
            }
            else {
                $class->_register_submeta_and_install($pkg, $sub, $types);
            }
        }
    };

    return;
}

sub Return :ATTR(CODE,BEGIN) {
    my $class = __PACKAGE__;
    my ($pkg, undef, $sub, undef, $types) = @_;
    $types //= [];

    push @RETURN_ARGS => [$pkg, $sub, $types];
    return;
}

sub meta {
    my ($sub) = @_;
    Sub::Meta::Library->get($sub);
}

sub wrap_sub {
    my ($class, $sub, $types) = @_;

    my $meta = Sub::Meta->new(sub => $sub);
    my $shortname = $meta->subname;

    { # check type
        my $file = $meta->file;
        my $line = $meta->line;
        for my $type (@$types) {
            for (qw/check get_message/) {
                die "Invalid type: $type. require `$_` method at $file line $line.\n"
                    unless $type->can($_)
            }
        }
    }

    my @src;
    push @src => sprintf('_croak "Required list context in fun %s because of multiple return values function" if !wantarray;', $shortname) if @$types > 1;

    # force LIST context.
    push @src => 'my @ret = &Scope::Upper::uplevel($sub, @_, &Scope::Upper::CALLER(0));';

    # return Empty List
    push @src => 'return if !@ret;' if @$types == 0;

    # check count
    push @src => sprintf(q|_croak "Too few return values for fun %s (expected %s, got @{[map { defined $_ ? $_ : 'undef' } @ret]})" if @ret < %d;|,
                         $shortname, "@$types", scalar @$types) if @$types > 0;

    push @src => sprintf(q|_croak "Too many return values for fun %s (expected %s, got @{[map { defined $_ ? $_ : 'undef' } @ret]})" if @ret > %d;|,
                         $shortname, "@$types", scalar @$types);

    # type check
    for my $i (0 .. $#$types) {
        push @src => sprintf(q|_croak "Invalid return in fun %s: return %d: @{[$types->[%d]->get_message($ret[%d])]}" unless $types->[%d]->check($ret[%d]);|, $shortname, $i, $i, $i, $i,$i)
    }

    push @src => 'return @ret;'    if @$types > 1;
    push @src => 'return $ret[0];' if @$types == 1;

    my $src = join "\n", @src;
    my $code = eval "sub { $src }"; ## no critic
    return $code;
}

sub _croak {
    my (undef, $file, $line) = caller 1;
    die @_, " at $file line $line.\n"
}

sub _register_submeta {
    my ($class, $pkg, $sub, $types) = @_;

    my $meta = Sub::Meta->new(sub => $sub, stashname => $pkg);
    $meta->set_returns(list => $types);

    if (my $materials = Sub::Meta::Finder::FunctionParameters::find_materials($sub)) {
        $meta->set_is_method($materials->{is_method});
        $meta->set_parameters($materials->{parameters});
    }

    Sub::Meta::Library->register($sub, $meta);
    return;
}

sub _register_submeta_and_install {
    my ($class, $pkg, $sub, $types) = @_;

    my $original_meta = Sub::Meta->new(sub => $sub);
    my $wrapped  = $class->wrap_sub($sub, $types);

    my $meta = Sub::Meta->new(sub => $wrapped, stashname => $pkg);
    $meta->set_returns(list => $types);

    if (my $materials = Sub::Meta::Finder::FunctionParameters::find_materials($sub)) {
        $meta->set_is_method($materials->{is_method});
        $meta->set_parameters($materials->{parameters});
    }

    $meta->apply_meta($original_meta);
    Sub::Meta::Library->register($wrapped, $meta);

    {
        no strict qw(refs);
        no warnings qw(redefine);
        *{$meta->fullname} = $wrapped;
    }
    return;
}

1;
__END__

=encoding utf-8

=head1 NAME

Function::Return - specify a function return type

=head1 SYNOPSIS

    use Function::Return;
    use Types::Standard -types;

    sub foo :Return(Int) { 123 }
    sub bar :Return(Int) { 3.14 }

    foo(); # 123
    bar(); # ERROR! Invalid type

    # multi return values
    sub baz :Return(Num, Str) { 3.14, 'message' }
    my ($pi, $msg) = baz();
    my $count = baz(); # ERROR! Required list context.

    # empty return
    sub boo :Return() { return; }
    boo();

=head1 DESCRIPTION

Function::Return allows you to specify a return type for your functions.

=head1 SUPPORT

This module supports all perl versions starting from v5.14.

=head1 IMPORT OPTIONS

=over 2

=item *
no_check

You can switch off type check.
If you change globally, use C<<$ENV{FUNCTION_RETURN_NO_CHECK}>>:

    BEGIN {
        $ENV{FUNCTION_RETURN_NO_CHECK} = 1;
    }
    use Function::Return;
    sub foo :Return(Int) { 3.14 }
    foo(); # NO ERROR!

And If you want to switch by a package, it is better to use the no_check option:

    use Function::Return no_check => 1;
    sub foo :Return(Int) { 3.14 }
    foo(); # NO ERROR!

=item *
pkg 

Function::Return automatically exports a return type by caller.

Or you can specify a package name:

    use Function::Return pkg => 'MyClass';

=back

=head1 ATTRIBUTES

=head2 Return

C<:Return> attribute is available.

=head1 FUNCTIONS

=head2 meta

This function lets you introspect return values:

    use Function::Return;
    use Types::Standard -types;

    sub baz() :Return(Str) { 'hello' }

    my $meta = Function::Return::meta \&baz; # Sub::Meta
    $meta->returns->list; # [Str]

In addition, it can be used with L<Function::Parameters>:

    use Function::Parameters;
    use Function::Return;
    use Types::Standard -types;

    fun hello(Str $msg) :Return(Str) { 'hello' . $msg }

    my $meta = Function::Return::meta \&hello; # Sub::Meta
    $meta->returns->list; # [Str]

    $meta->args->[0]->type; # Str
    $meta->args->[0]->name; # $msg

    # Note
    Function::Parameters::info \&hello; # undef

This makes it possible to know both type information of function arguments and return value at compile time, making it easier to use for testing etc.

=head1 METHODS

=head2 wrap_sub($coderef)

This interface is for power-user. Rather than using the C<< :Return >> attribute, it's possible to wrap a coderef like this:

    my $wrapped = Function::Return->wrap_sub($orig, [Str]);
    $wrapped->();

=head1 NOTE

=head2 enforce LIST to simplify

C<Function::Return> makes the original function is called in list context whether the wrapped function is called in list, scalar, void context:

    sub foo :Return(Str) { wantarray ? 'LIST!!' : 'NON!!' }
    my $a = foo(); # => LIST!!

The specified type checks against the value the original function was called in the list context.

C<wantarray> is convenient, but it sometimes causes confusion. So, in this module, we prioritize that it easy to understand the type of function return value.

=head2 requirements of type constraint

The requirements of type constraint of C<Function::Return> is the same as for L<Function::Parameters>. Specific requirements are as follows:

> The only requirement is that the returned value (here referred to as $tc, for "type constraint") is an object that provides $tc->check($value) and $tc->get_message($value) methods. check is called to determine whether a particular value is valid; it should return a true or false value. get_message is called on values that fail the check test; it should return a string that describes the error.

=head2 compare Return::Type

Both L<Return::Type> and C<Function::Return> perform type checking on function return value, but have some differences.

1. C<Function::Return> is not possible to specify different type constraints for scalar and list context, but C<Return::Type> is possible.

2. C<Function::Return> check type constraint for void context, but C<Return::Type> doesn't.

3. C<Function::Return::Meta#get> can be used together with C<Function::Parameters::Info>, but C<Return::Type> seems a bit difficult.

=head1 SEE ALSO

L<Sub::Meta>

=head1 LICENSE

Copyright (C) kfly8.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kfly8 E<lt>kfly@cpan.orgE<gt>

=cut

