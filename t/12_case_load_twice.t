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
isa_ok $info, 'Function::Parameters::Info';

done_testing;
