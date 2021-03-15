package Function::Return;

use v5.14.0;
use warnings;

our $VERSION = "0.08";

use Attribute::Handlers;
use B::Hooks::EndOfScope;
use Function::Return::Meta;
use namespace::autoclean;

sub import {
    my $class = shift;
    my %args = @_;

    my $pkg = $args{pkg} ? $args{pkg} : scalar caller;
    Function::Return::Meta->_set_no_check($pkg, $args{no_check}) if exists $args{no_check};

    {
        # allow importing package to use attribute
        no strict 'refs';
        push @{"${pkg}::ISA"}, $class;
    }

    return;
}

sub Return :ATTR(CODE,BEGIN) {
    my $class = __PACKAGE__;
    my ($pkg, undef, $sub, $attr, $types) = @_;
    $types //= [];

    on_scope_end {
        if (Function::Return::Meta->_no_check($pkg)) {
            Function::Return::Meta->_register_submeta($pkg, $sub, $types);
        }
        else {
            Function::Return::Meta->_register_submeta_and_install($pkg, $sub, $types);
        }
    };
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

=head2 SUPPORT

This module supports all perl versions starting from v5.14.

=head2 IMPORT OPTIONS

=head3 no_check

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

=head3 pkg

Function::Return automatically exports a return type by caller.

Or you can specify a package name:

    use Function::Return pkg => 'MyClass';

=head1 NOTE

=head2 handling meta information

L<Function::Return::Meta> can handle the meta information of C<Function::Return>:

    use Function::Return;
    use Function::Return::Meta;
    use Types::Standard -types;

    sub baz() :Return(Str) { 'hello' }

    my $meta = Function::Return::Meta->get(\&baz); # Sub::Meta
    $meta->returns->list; # [Str]

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

L<Function::Return::Meta>

=head1 LICENSE

Copyright (C) kfly8.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kfly8 E<lt>kfly@cpan.orgE<gt>

=cut

