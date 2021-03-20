use strict;
use warnings;
use Test::More;
use Test::Fatal;

use Function::Return;

ok !__PACKAGE__->can('Return');
ok !(__PACKAGE__->can('on_scope_end'));
ok !(__PACKAGE__->can('meta'));
ok !(__PACKAGE__->can('no_check'));
ok !(__PACKAGE__->can('wrap_sub'));

done_testing;
