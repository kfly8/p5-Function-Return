use strict;
use warnings;
use Test::More;
use Test::Fatal;

use Function::Parameters;
use Function::Return;
use Types::Standard -types;
use Sub::Util qw(subname);

sub single :Return(Str) { }
sub multi :Return(Str, Int) { }
sub empty :Return() { }
sub no { }

fun with_fp_fun(Str $a) :Return(Num) { }
method with_fp_method(Str $b) :Return(Num) { }

package NoCheck {
    use Function::Return no_check => 1;
    use Function::Parameters;
    use Types::Standard -types;

    sub single :Return(Str) { }
    sub multi :Return(Str, Int) { }
    sub empty :Return() { }
    sub no { }

    fun with_fp_fun(Str $a) :Return(Num) { }
    method with_fp_method(Str $b) :Return(Num) { }
}

subtest 'single' => sub {
    for my $code (\&single, \&NoCheck::single) {
        subname($code);
        my $meta = Function::Return::Meta->get($code);
        isa_ok $meta, 'Sub::Meta';
        is_deeply $meta->returns->list, [Str];
    }
};

subtest 'multi' => sub {
    for my $code (\&multi, \&NoCheck::multi) {
        note subname($code);
        my $meta = Function::Return::Meta->get($code);
        isa_ok $meta, 'Sub::Meta';
        is_deeply $meta->returns->list, [Str, Int];
    }
};

subtest 'empty' => sub {
    for my $code (\&empty, \&NoCheck::empty) {
        note subname($code);
        my $meta = Function::Return::Meta->get($code);
        isa_ok $meta, 'Sub::Meta';
        is_deeply $meta->returns->list, [];
    }
};

subtest 'no' => sub {
    for my $code (\&no, \&NoCheck::no) {
        note subname($code);
        my $meta = Function::Return::Meta->get($code);
        is $meta, undef;
    }
};

subtest 'with_fp_fun' => sub {
    for my $code (\&with_fp_fun, \&NoCheck::with_fp_fun) {
        note subname($code);
        my $meta = Function::Return::Meta->get($code);
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
    }
};

subtest 'with_fp_method' => sub {
    for my $code (\&with_fp_method, \&NoCheck::with_fp_method) {
        note subname($code);
        my $meta = Function::Return::Meta->get($code);
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
    }
};

done_testing;
