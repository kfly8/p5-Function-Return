package Sample;

use Function::Return;
use Types::Standard -types;

sub invalid :Return(Str) {
    return { };
}

1;
