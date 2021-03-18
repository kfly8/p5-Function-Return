use strict;
use warnings;
use Test::More;
use Test::Fatal;

use lib 't/lib';

use Cola;

lives_ok { Cola::drink() };
dies_ok { Cola::invalid() };

done_testing;
