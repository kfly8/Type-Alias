use strict;
use warnings;
use Test::More;

use Type::Alias -declare => [qw( X Y List )];
use Types::Standard -types;

subtest 'type alias' => sub {

    type X => Str;
    type Y => Int;

    is X, Str;
    is Y, Int;

    is X | Y, Str | Int;
    TODO: {
        local $TODO = '&X() & &Y() is not supported yet';
        is X & Y, Str & Int;
    }
};

subtest 'type function' => sub {

    type List => sub {
        my ($R) = @_;
        $R ? ArrayRef[$R] : ArrayRef;
    };

    is List[Str], ArrayRef[Str];
    is List[], ArrayRef;
    is List, ArrayRef;
};

subtest 'type alias and type function' => sub {

    is X | List, Str | ArrayRef;
    TODO: {
        local $TODO = '&X() & &List() is not supported yet';
        is X & List, Str & ArrayRef;
    }
};

done_testing;
