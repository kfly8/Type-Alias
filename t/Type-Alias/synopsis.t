use strict;
use warnings;
use Test::More;

use Type::Alias -alias => [qw(ID User UserData)], -fun => [qw(List)];
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

type UserData => List[User] | User;

ok UserData->check([
    { id => '1', name => 'foo', age => 20 },
    { id => '2', name => 'bar', age => 30 },
]);

ok UserData->check(
    { id => '1', name => 'foo', age => 20 },
);

done_testing;
