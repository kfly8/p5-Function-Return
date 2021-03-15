use strict;
use warnings;
use Test::More;
use Test::Fatal;

use Function::Return;

ok main->can('Return');
ok !main->can('on_scope_end');
ok !main->can('meta');
ok !main->can('no_check');
ok !main->can('wrap_sub');

done_testing;
