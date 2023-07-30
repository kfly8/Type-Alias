requires 'perl', '5.020000';

requires 'Type::Tiny';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Requires';
};

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};
