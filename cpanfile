requires 'perl', '5.014004';
requires 'attributes';
requires 'Attribute::Handlers';
requires 'Sub::Util';
requires 'Sub::Info';
requires 'Sub::Meta', '0.08';
requires 'Scalar::Util';
requires 'Scope::Upper';
requires 'Function::Parameters', '2.000003';
requires 'B::Hooks::EndOfScope', '0.23';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Fatal';
    requires 'Types::Standard';
    requires 'Module::Build::Tiny', 0.035;
};

