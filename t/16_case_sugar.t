use strict;
use warnings;
use Test::More;

use lib 't/lib';

use Sugar;

sub foo :Return() {123}

ok dies { foo() }

done_testing;
