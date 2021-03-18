package Brown;
use strict;
use warnings;

sub import {
    my $class  = shift;
    my $target = shift;

    require 'Function/Return.pm';
    Function::Return->import(pkg => $target);

    require 'Types/Standard.pm';
    Types::Standard->import('Str');

    EXPORT_TYPE: {
        no strict 'refs'; ## no critic
        *{"${target}::Str"} = \&{"Brown::Str"};
    }
}

1;
