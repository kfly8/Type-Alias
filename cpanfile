requires 'perl', '5.016000';

requires 'Type::Tiny';
requires 'B::Hooks::EndOfScope';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

