use strict;
use warnings;
use Test::More;
use Test::Fatal;

use lib 't/lib';

# lazy load
require Sample;

like exception { Sample::invalid() }, qr!^Invalid return in fun invalid: return!;

done_testing;
