package Sugar;

use Import::Into;

sub import {
    my $caller = caller;

    Types::Standard->import::into($caller, '-types');
    Function::Return->import::into($caller);
}

1;
