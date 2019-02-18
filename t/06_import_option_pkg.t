use strict;
use warnings;
use Test::More;

use Function::Return pkg => 'MyPkg';

is(MyPkg->foo, 123);

done_testing;

package MyPkg;
use Types::Standard 'Int';

sub foo :Return(Int) { 123 }
