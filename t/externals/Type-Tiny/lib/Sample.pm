package Sample;
use strict;
use warnings;

our @EXPORT_OK = qw( hello world ID User List );

use Type::Library -base, -declare => qw( Bar );
use Type::Alias -declare => [qw( ID User List)];
use Types::Standard -types;

sub hello { "HELLO" }
sub world { "WORLD" }

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

1;
