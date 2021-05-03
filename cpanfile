requires 'perl', '5.014004';

requires 'Attribute::Handlers';
requires 'Sub::Meta', '0.08';
requires 'Scope::Upper';
requires 'Function::Parameters', '2.000003';
requires 'B::Hooks::EndOfScope', '0.23';
requires 'namespace::autoclean';

on 'configure' => sub {
    requires 'Module::Build::Tiny', 0.035;
};

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Fatal';
    requires 'Types::Standard';
};

