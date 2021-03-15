use strict;
use warnings;
use Test::More;
use Test::Fatal;

use Function::Return pkg => 'MyPkg';

is(MyPkg->foo, 123);
ok exception { MyPkg->invalid };

done_testing;

package MyPkg;
use Types::Standard 'Int';

sub foo :Return(Int) { 123 }
sub invalid :Return(Int) { }
