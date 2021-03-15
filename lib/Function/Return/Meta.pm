package Function::Return::Meta;

use v5.14.0;
use warnings;

our $VERSION = "0.07";

use Scope::Upper ();
use Sub::Meta;
use Sub::Meta::Library;
use Sub::Meta::Creator;
use Sub::Meta::Finder::FunctionParameters;

use constant DEFAULT_NO_CHECK => !!($ENV{FUNCTION_RETURN_NO_CHECK} // 0);
my %NO_CHECK;

sub get {
    my ($class, $sub) = @_;
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

    my $src = q|
sub {
    _croak "Required list context in fun $shortname because of multiple return values function"
        if @$types > 1 && !wantarray;

    # force LIST context.
    my @ret = &Scope::Upper::uplevel($sub, @_, &Scope::Upper::CALLER(0));

    # return Empty List
    return if @$types == 0 && !@ret;

    _croak "Too few return values for fun $shortname (expected @$types, got @{[map { defined $_ ? $_ : 'undef' } @ret]})" if @ret < @$types;
    _croak "Too many return values for fun $shortname (expected @$types, got @{[map { defined $_ ? $_ : 'undef' } @ret]})" if @ret > @$types;

    for my $i (0 .. $#$types) {
        my $type  = $types->[$i];
        my $value = $ret[$i];
        _croak "Invalid return in fun $shortname: return $i: @{[$type->get_message($value)]}" unless $type->check($value);
    }

    return @$types > 1 ? @ret # multi return
         : $ret[0]            # single return
};
|;

    my $code = eval $src; ## no critic
    if ($@) {
        _croak $@;
    }
    return $code;
}



sub _set_no_check {
    my ($class, $pkg, $flag) = @_;
    $NO_CHECK{$pkg} = !!$flag;
}

sub _no_check {
    my ($class, $pkg) = @_;
    $NO_CHECK{$pkg} // DEFAULT_NO_CHECK;
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

Function::Return::Meta - handle subroutine return types

=head1 SYNOPSIS

    use Function::Return;
    use Function::Return::Meta;
    use Types::Standard -types;

    sub foo :Return(Int) { 123 }
    sub bar { }

    my $meta = Function::Return::Meta->get(\&foo);
    
    my $wrapped = Function::Return::Meta->wrap_sub(\&bar, [Str]);
    $wrapped->();

=head2 CLASS METHODS

=head3 get($coderef)

This method lets you introspect return values:

    use Function::Return;
    use Function::Return::Meta;
    use Types::Standard -types;

    sub baz() :Return(Str) { 'hello' }

    my $meta = Function::Return::Meta->get(\&baz); # Sub::Meta
    $meta->returns->list; # [Str]

In addition, it can be used with L<Function::Parameters>:

    use Function::Parameters;
    use Function::Return;
    use Function::Return::Meta;
    use Types::Standard -types;

    fun hello(Str $msg) :Return(Str) { 'hello' . $msg }

    my $meta = Function::Return::Meta->get(\&hello); # Sub::Meta
    $meta->returns->list; # [Str]

    $meta->args->[0]->type; # Str
    $meta->args->[0]->name; # $msg

    # Note
    Function::Parameters::info \&hello; # undef

This makes it possible to know both type information of function arguments and return value at compile time, making it easier to use for testing etc.

=head3 wrap_sub($coderef)

This interface is for power-user. Rather than using the C<< :Return >> attribute, it's possible to wrap a coderef like this:

    my $wrapped = Function::Return->wrap_sub($orig, [Str]);
    $wrapped->();

=head1 LICENSE

Copyright (C) kfly8.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kfly8 E<lt>kfly@cpan.orgE<gt>

=cut

