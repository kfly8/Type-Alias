use strict;
use warnings;
use Test::More;

use Type::Alias -declare => qw(ID User List Hoge);
use Types::Standard -types;

type ID => Str;

type User => {
    id   => ID,
    name => Str,
    age  => Int,
};

type List => sub {
    my ($R) = @_;
    $R ? ArrayRef[$R] : ArrayRef;
};

type Hoge => List[User] | User;

is ID, Str;
is User, Dict[age => Int, id => Str, name => Str];
is List[Str], ArrayRef[Str];
is Hoge, ArrayRef[ Dict[age => Int, id => Str, name => Str] ] | Dict[age => Int, id => Str, name => Str];

our @EXPORT_OK;
is_deeply \@EXPORT_OK, [qw(ID User List Hoge)];

done_testing;
