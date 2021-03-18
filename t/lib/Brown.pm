package Brown;
use strict;
use warnings;

require 'Function/Return.pm';
Function::Return->import(pkg => 'Bear');

require 'Types/Standard.pm';
Types::Standard->import('Str');

EXPORT_TYPE: {
    no strict 'refs'; ## no critic
    *{"Bear::Str"} = \&{"Brown::Str"};
}

1;
