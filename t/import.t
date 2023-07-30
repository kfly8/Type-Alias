use strict;
use warnings;
use Test::More;

use Types::Standard qw(Str);

subtest '-declare option predefine type aliases.' => sub {

    package TestOptionDeclare {
        use Type::Alias -declare => [qw(Foo)];
    };

    ok +TestOptionDeclare->can('Foo'), 'predefined Foo';
    eval { TestOptionDeclare::Foo() };
    like $@, qr/should define type alias 'Foo'/;

    subtest 'If Alrealy exists same name function, cannot predeclare type alias.' => sub {
        eval '
            package TestErrorDeclare {
                sub Foo { ... }
                use Type::Alias -declare => [qw(Foo)];
            };
        ';
        like $@, qr/Cannot predeclare type alias 'TestErrorDeclare::Foo'/;
    };
};

subtest '-type_alias option specify type_alias function name, which default is `type`.' => sub {

    package TestOptionTypeAlias {
        use Type::Alias -type_alias => 'mytype', -declare => [qw(Foo)];
        use Types::Standard qw(Str);

        mytype Foo => Str;
    };
    is TestOptionTypeAlias::Foo, Str;

    eval '
        package TestErrorTypeAlias {
            sub type { ... }
            use Type::Alias;
        };
    }';
    like $@, qr/Alreay exists function 'TestErrorTypeAlias::type'/;
};

subtest '-export_ok option' => sub {
    subtest 'Push -export_ok to @EXPORT_OK ' => sub {
        package TestOptionExportOk {
            use Type::Alias -declare => [qw(Foo Bar)], -export_ok => [qw(Bar)];
            our @EXPORT_OK;
        };
        is_deeply \@TestOptionExportOk::EXPORT_OK, ['Bar'];
    };

    subtest 'Push automaticaly type alises to @EXPORT_OK ' => sub {
        package TestNoOptionExportOk {
            use Type::Alias -declare => [qw(Foo)];
            our @EXPORT_OK;
        };
        is_deeply \@TestNoOptionExportOk::EXPORT_OK, ['Foo'];
    };

    subtest 'If you specify -export_ok option that include type alias not declared, throw error.' => sub {
        eval '
            package TestIllegalExportOk {
                use Type::Alias -declare => [qw(Foo)], -export_ok => [qw(Bar)];
                our @EXPORT_OK;
            };
        }';
        like $@, qr/Type alias 'Bar' is not declared/;
    };
};

done_testing;
