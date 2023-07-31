use strict;
use warnings;
use Test::More;

use Types::Standard qw(Str);

subtest '-alias option predefine type aliases.' => sub {

    package TestOptionAlias {
        use Type::Alias -alias => [qw(Foo)];
    };

    ok +TestOptionAlias->can('Foo'), 'predefined Foo';
    is prototype(\&TestOptionAlias::Foo), '', 'no argument';
    eval { TestOptionAlias::Foo() };
    like $@, qr/should define type alias 'Foo'/;

    subtest 'If Alrealy exists same name function, cannot predeclare type alias.' => sub {
        eval '
            package TestErrorAlias {
                sub Foo { ... }
                use Type::Alias -alias => [qw(Foo)];
            };
        ';
        like $@, qr/Cannot predeclare type alias 'TestErrorAlias::Foo'/;
    };
};

subtest '-fun option predefine type functions.' => sub {

    package TestOptionFun {
        use Type::Alias -fun => [qw(Foo)];
    };

    ok +TestOptionFun->can('Foo'), 'predefined Foo';
    is prototype(\&TestOptionFun::Foo), ';$', 'argument is optional';

    eval { TestOptionFun::Foo() };
    like $@, qr/should define type function 'Foo'/;

    subtest 'If Alrealy exists same name function, cannot predeclare type function.' => sub {
        eval '
            package TestErrorFun {
                sub Foo { ... }
                use Type::Alias -fun => [qw(Foo)];
            };
        ';
        like $@, qr/Cannot predeclare type function 'TestErrorFun::Foo'/;
    };
};

subtest '-type_alias option specify type_alias function name, which default is `type`.' => sub {

    package TestOptionTypeAlias {
        use Type::Alias -type_alias => 'mytype', -alias => [qw(Foo)];
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

done_testing;
