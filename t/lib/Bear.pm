package Bear;
use strict;
use warnings;

use Brown 'Bear';

use Frog 'hoge';

sub foo :Return(Str) { Frog->bar; }

sub horse :Return(Str) { hoge(); }

1;
