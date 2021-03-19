use strict;
use warnings;
use Test::More;
use Test::Fatal qw(lives_ok);

use lib 't/lib';

use SampleExporter qw(hoge);

lives_ok { hoge() };

done_testing;
