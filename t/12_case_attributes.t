use strict;
use warnings;
use Test::More;

use lib 't/lib';

use DeadAttrSample;
use DeadAttrSampleWithFunctionReturn;

like exception { DeadAttrSample::case_multi_attributes() }, qr/Dead!/;
like exception { DeadAttrSampleWithFunctionReturn::case_multi_attributes() }, qr/Dead!/;

done_testring;
