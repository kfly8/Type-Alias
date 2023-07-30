use strict;
use warnings;
use Test::More;

use Type::Alias ();
use Types::Standard -types;

package MyType {
    sub new { bless {}, shift }
    sub check { 1 }
    sub get_message { 'ok' }
}

subtest 'If type constraint object is passed, return it.' => sub {
    subtest 'If Type::Tiny object is passed, return it.' => sub {
        is Type::Alias::to_type(Int), Int;
        is Type::Alias::to_type(Str), Str;
        is Type::Alias::to_type(ArrayRef[Int]), ArrayRef[Int];
    };

    subtest 'If MyType object is passed, return it.' => sub {
        my $type = MyType->new;
        is Type::Alias::to_type($type), $type;
    };

    subtest 'If object which not define check and get_message methods, throw error.' => sub {
        my $type = bless {}, 'Some';
        eval { Type::Alias::to_type($type) };
        ok $@;
    };
};

subtest 'If one element arrayref is passed, return ArrayRef type.' => sub {
    is Type::Alias::to_type([Int]), ArrayRef[Int];
    is Type::Alias::to_type([Str]), ArrayRef[Str];
    is Type::Alias::to_type([Dict[a => Str]]), ArrayRef[Dict[a => Str]];
    is Type::Alias::to_type([{ a => Str }]), ArrayRef[Dict[a => Str]];
};

subtest 'If two or more element arrayref is passed, return Tuple type.' => sub {
    is Type::Alias::to_type([Int, Str]), Tuple[Int, Str];
    is Type::Alias::to_type([Str, Int]), Tuple[Str, Int];
    is Type::Alias::to_type([Str, Int, Str]), Tuple[Str, Int, Str];
    is Type::Alias::to_type([Str, { a => Int }]), Tuple[Str, Dict[a => Int]];
};

subtest 'If hashref is passed, return Dict type.' => sub {
    is Type::Alias::to_type({some => [Int, Str]}), Dict[some => Tuple[Int, Str]];

    note 'Dict keys is sorted by alphabetical order.';
    is Type::Alias::to_type({a => Int, b => Int, c => Int}), Dict[a => Int, b => Int, c => Int];
    is Type::Alias::to_type({b => Int, a => Int, c => Int}), Dict[a => Int, b => Int, c => Int];
};

subtest 'If coderef is passed, return wrapped coderef which returns type. that is, return type function' => sub {
    my $coderef = sub {
        my ($R) = @_;
        [$R]
    };

    my $type = Type::Alias::to_type($coderef);
    is ref $type, 'CODE', 'return type function';

    subtest 'If type function is passed arguments, generate type using the arguments.' => sub {
        is $type->([Int]), ArrayRef[Int];
        is $type->([Str]), ArrayRef[Str];
        is $type->([{a => Int}]), ArrayRef[ Dict[a => Int] ], 'The arguments of type function become type through Type::Alias::to_type.';

        eval { $type->(Int) };
        ok $@, 'Type function requires arguments to be arrayref.';
    };
};

subtest 'If scalarref is passed, throw error.' => sub {
    eval { Type::Alias::to_type(\1) };
    ok $@;
};

subtest 'If regexref is passed, throw error.' => sub {
    eval { Type::Alias::to_type(qr/foo/) };
    ok $@;
};

subtest 'If scalar is passed, throw error.' => sub {
    eval { Type::Alias::to_type(123) };
    ok $@, 'does not support number';

    eval { Type::Alias::to_type('hello') };
    ok $@, 'does not support string';

    eval { Type::Alias::to_type(!!1) };
    ok $@, 'does not support boolean';

    eval { Type::Alias::to_type(undef) };
    ok $@, 'does not support undef';
};

done_testing;
