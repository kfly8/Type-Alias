use strict;
use warnings;
use Test::More;

use Type::Alias ();
use Types::Standard -types;

subtest 'If type constraint object is passed, return type alias coderef.' => sub {
    my $type_alias = Type::Alias::generate_type_alias(Int);
    is $type_alias->(), Int;

    is prototype($type_alias), ';$';
    eval { $type_alias->(1) };
    ok $@, 'If type alias is not type function, cannot accept arguments';
};

subtest 'If arrayref is passed, return Tuple type alias coderef.' => sub {
    my $type_alias = Type::Alias::generate_type_alias([Int, Str]);
    is $type_alias->(), Tuple[Int, Str];
};

subtest 'If hashref is passed, return Dict type alias coderef.' => sub {
    my $type_alias = Type::Alias::generate_type_alias({ id => Int, name => Str });
    is $type_alias->(), Dict[id => Int, name => Str];
};

subtest 'If coderef is passed, return type function coderef.' => sub {
    my $coderef = sub {
        my ($R) = @_;
        $R ? ArrayRef[$R] : ArrayRef;
    };

    my $type_alias = Type::Alias::generate_type_alias($coderef);
    is $type_alias->([Int]), ArrayRef[Int];
};

done_testing;
