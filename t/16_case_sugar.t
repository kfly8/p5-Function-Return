use strict;
use warnings;
use Test::More;
use Test::Fatal qw(lives_ok dies_ok);

use lib 't/lib';

use Cola;

lives_ok { Cola::drink() };
dies_ok { Cola::invalid() };

done_testing;
