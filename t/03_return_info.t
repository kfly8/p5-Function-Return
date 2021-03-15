use strict;
use warnings;
use Test::More;
use Test::Fatal;

use Function::Parameters;
use Function::Return;
use Types::Standard -types;

sub single :Return(Str) { }
sub multi :Return(Str, Int) { }
sub empty :Return() { }
sub no { }

fun with_fp_fun(Str $a) :Return(Num) { }
method with_fp_method(Str $b) :Return(Num) { }

subtest 'single' => sub {
    my $meta = Function::Return::meta \&single;
    isa_ok $meta, 'Sub::Meta';
    is_deeply $meta->returns->list, [Str];
};

subtest 'multi' => sub {
    my $meta = Function::Return::meta \&multi;
    isa_ok $meta, 'Sub::Meta';
    is_deeply $meta->returns->list, [Str, Int];
};

subtest 'empty' => sub {
    my $meta = Function::Return::meta \&empty;
    isa_ok $meta, 'Sub::Meta';
    is_deeply $meta->returns->list, [];
};

subtest 'no' => sub {
    my $meta = Function::Return::meta \&no;
    is $meta, undef;
};

subtest 'with_fp_fun' => sub {
    my $meta = Function::Return::meta \&with_fp_fun;
    isa_ok $meta, 'Sub::Meta';
    is_deeply $meta->returns->list, [Num];

    my $pinfo = Function::Parameters::info \&with_fp_fun;
    is $pinfo, undef;
    ok !$meta->is_method;
    is scalar @{$meta->args}, 1;
    is $meta->args->[0]->type, Str;
    is $meta->args->[0]->name, '$a';
    ok $meta->args->[0]->positional;
    ok $meta->args->[0]->required;
};

subtest 'with_fp_method' => sub {
    my $meta = Function::Return::meta \&with_fp_method;
    isa_ok $meta, 'Sub::Meta';
    is_deeply $meta->returns->list, [Num];

    my $pinfo = Function::Parameters::info \&with_fp_method;
    is $pinfo, undef;

    ok $meta->is_method;
    is scalar @{$meta->args}, 1;
    is $meta->args->[0]->type, Str;
    is $meta->args->[0]->name, '$b';
    ok $meta->args->[0]->positional;
    ok $meta->args->[0]->required;
};

done_testing;
