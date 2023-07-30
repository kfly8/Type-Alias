requires 'perl', '5.020000';

requires 'Type::Tiny';
requires 'B::Hooks::EndOfScope';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};
