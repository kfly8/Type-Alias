use strict;
use warnings;
use Test::More;

use Type::Alias -declare => [qw(ID User List)];
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

is List[Str], ArrayRef[Str];

our @EXPORT_OK;
is_deeply \@EXPORT_OK, [qw(ID User List)];

done_testing;
