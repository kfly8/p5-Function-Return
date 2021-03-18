use strict;
use warnings;
use lib 't/lib';
use Test::More;

use Bear;

is Bear::foo(), 'baz';

is Bear::horse(), 'hogera';

done_testing;
