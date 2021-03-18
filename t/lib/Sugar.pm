package Sugar;

sub import {
    my $caller = caller;

    require Types::Standard;
    Types::Standard->import('-types');

    require Function::Return;
    Function::Return->import(pkg => $caller);
}

1;
