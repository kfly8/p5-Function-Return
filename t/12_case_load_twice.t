use strict;
use warnings;
use Test::More;
use Test::Fatal;
use Function::Parameters;

# load twice
use Function::Return;
use Function::Return;

fun hello() :Return() { }
my $info = Function::Parameters::info(\&hello);
is $info, undef;

my $meta = Function::Return::Meta->get(\&hello);
isa_ok $meta, 'Sub::Meta';

done_testing;
