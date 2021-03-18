use strict;
use warnings;
use lib 't/lib';
use Test::More;

use Bear;

is Bear::foo(), 'bar';

done_testing;
