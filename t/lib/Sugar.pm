package Sugar;

sub import {
    my $caller = caller;

    require Function::Return;
    Function::Return->import(pkg => $caller);
}

1;
