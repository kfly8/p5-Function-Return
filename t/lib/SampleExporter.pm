package SampleExporter;

use Function::Return;
use parent qw(Exporter);

our @EXPORT_OK = qw(hoge);

sub hoge :Return() { }

1;
