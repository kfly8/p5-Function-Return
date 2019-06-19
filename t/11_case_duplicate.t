use strict;
use warnings;
use lib 't/lib';
use Test::More;

use Function::Return;

package Foo {
    use Function::Parameters;
    use Function::Return;

    fun hello() :Return() { }
}

use Sample;
my $code = Sample->can('invalid');
my $info = Function::Parameters::info($code);
is $info, undef;

done_testing;
