package Frog;
use strict;
use warnings;

use Brown 'Frog';
use parent qw/Exporter/;
our @EXPORT_OK = qw/
    hoge
/;

sub bar :Return(Str) { 'baz' }

sub hoge :Return(Str) { 'hogera' }

1;
