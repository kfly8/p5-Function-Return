package DeadAttrSampleWithFunctionReturn;
use DeadAttr;
use Function::Return;

sub case_multi_attributes :Dead :Return() { $_[0] }
1;
