[![Actions Status](https://github.com/kfly8/p5-Function-Return/workflows/test/badge.svg)](https://github.com/kfly8/p5-Function-Return/actions) [![Coverage Status](https://img.shields.io/coveralls/kfly8/p5-Function-Return/master.svg?style=flat)](https://coveralls.io/r/kfly8/p5-Function-Return?branch=master) [![MetaCPAN Release](https://badge.fury.io/pl/Function-Return.svg)](https://metacpan.org/release/Function-Return)
# NAME

Function::Return - specify a function return type

# SYNOPSIS

```perl
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
```

# DESCRIPTION

Function::Return allows you to specify a return type for your functions.

## SUPPORT

This module supports all perl versions starting from v5.14.

## IMPORT OPTIONS

### no\_check

You can switch off type check.
If you change globally, use `<$ENV{FUNCTION_RETURN_NO_CHECK}`>:

```perl
BEGIN {
    $ENV{FUNCTION_RETURN_NO_CHECK} = 1;
}
use Function::Return;
sub foo :Return(Int) { 3.14 }
foo(); # NO ERROR!
```

And If you want to switch by a package, it is better to use the no\_check option:

```perl
use Function::Return no_check => 1;
sub foo :Return(Int) { 3.14 }
foo(); # NO ERROR!
```

### pkg

Function::Return automatically exports a return type by caller.

Or you can specify a package name:

```perl
use Function::Return pkg => 'MyClass';
```

## FUNCTIONS

### Function::Return::meta($coderef)

The function `Function::Return::meta` lets you introspect return values:

```perl
use Function::Return;
use Types::Standard -types;

sub baz() :Return(Str) { 'hello' }

my $meta = Function::Return::meta \&baz; # Sub::Meta
$meta->returns->list; # [Str]
```

In addition, it can be used with [Function::Parameters](https://metacpan.org/pod/Function%3A%3AParameters):

```perl
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
```

This makes it possible to know both type information of function arguments and return value at compile time, making it easier to use for testing etc.

## CLASS METHODS

### wrap\_sub($coderef)

This interface is for power-user. Rather than using the `:Return` attribute, it's possible to wrap a coderef like this:

```perl
my $wrapped = Function::Return->wrap_sub($orig, [Str]);
$wrapped->();
```

# NOTE

## enforce LIST to simplify

`Function::Return` makes the original function is called in list context whether the wrapped function is called in list, scalar, void context:

```perl
sub foo :Return(Str) { wantarray ? 'LIST!!' : 'NON!!' }
my $a = foo(); # => LIST!!
```

The specified type checks against the value the original function was called in the list context.

`wantarray` is convenient, but it sometimes causes confusion. So, in this module, we prioritize that it easy to understand the type of function return value.

## requirements of type constraint

The requirements of type constraint of `Function::Return` is the same as for `Function::Parameters`. Specific requirements are as follows:

\> The only requirement is that the returned value (here referred to as $tc, for "type constraint") is an object that provides $tc->check($value) and $tc->get\_message($value) methods. check is called to determine whether a particular value is valid; it should return a true or false value. get\_message is called on values that fail the check test; it should return a string that describes the error.

## compare Return::Type

Both `Return::Type` and `Function::Return` perform type checking on function return value, but have some differences.

1\. `Function::Return` is not possible to specify different type constraints for scalar and list context, but `Return::Type` is possible.

2\. `Function::Return` check type constraint for void context, but `Return::Type` doesn't.

3\. `Function::Return::meta` can be used together with `Function::Parameters::Info`, but `Return::Type` seems a bit difficult.

# SEE ALSO

[Function::Parameters](https://metacpan.org/pod/Function%3A%3AParameters), [Return::Type](https://metacpan.org/pod/Return%3A%3AType)

# LICENSE

Copyright (C) kfly8.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

kfly8 <kfly@cpan.org>
