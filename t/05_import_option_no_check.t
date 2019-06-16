use strict;
use warnings;
use Test::More;
use Test::Fatal;

package Check {
    use Function::Return;
    use Types::Standard -types;

    sub case_valid :Return(Int) { 123 }
    sub case_invalid :Return(Int) { undef }
}

package NoCheck {
    use Function::Return no_check => 1;
    use Types::Standard -types;

    sub case_valid :Return(Int) { 123 }
    sub case_invalid :Return(Int) { undef }
}

ok(!exception { Check::case_valid() }, 'valid');
like exception { Check::case_invalid() }, qr!^Invalid return in fun!, 'invalid';
ok(!exception { NoCheck::case_valid() }, 'valid');
ok(!exception { NoCheck::case_invalid() }, 'NO ERROR');

done_testing;
