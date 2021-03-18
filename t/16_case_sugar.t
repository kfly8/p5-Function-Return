use strict;
use warnings;
use Test::More;
use Test::Fatal;

use lib 't/lib';

use Sugar;

sub foo :Return() {123}

ok exception { foo() };

done_testing;
