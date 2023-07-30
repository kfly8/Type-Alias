use strict;
use warnings;
use Test::More;

use Types::Standard qw(Str);

subtest '-declare option predefine type aliases.' => sub {

    package TestOptionDeclare {
        use Type::Alias -declare => qw(Foo);
    };

    ok +TestOptionDeclare->can('Foo'), 'predefined Foo';
    eval { TestOptionDeclare::Foo };
    like $@, qr/should define type alias 'Foo'/;
};

subtest 'Push automaticaly type alises to @EXPORT_OK ' => sub {

    package TestOptionDeclareWithExportOk {
        use Type::Alias -declare => qw(Foo);
        our @EXPORT_OK;
    };

    is_deeply \@TestOptionDeclareWithExportOk::EXPORT_OK, ['Foo'];
};

subtest 'If Alrealy exists same name function, cannot predeclare type alias.' => sub {
    eval '
        package TestErrorDeclare {
            sub Foo { ... }
            use Type::Alias -declare => qw(Foo);
        };
    ';
    like $@, qr/Cannot predeclare type alias 'Foo'/;
};

subtest '-type_alias option specify type_alias function name, which default is `type`.' => sub {

    package TestOptionTypeAlias {
        use Type::Alias -type_alias => 'mytype', -declare => qw(Foo);
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
    like $@, qr/Alreay exists function 'type'/;
};

done_testing;
