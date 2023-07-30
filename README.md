[![Actions Status](https://github.com/kfly8/Type-Alias/actions/workflows/test.yml/badge.svg)](https://github.com/kfly8/Type-Alias/actions) [![Coverage Status](https://img.shields.io/coveralls/kfly8/Type-Alias/main.svg?style=flat)](https://coveralls.io/r/kfly8/Type-Alias?branch=main) [![MetaCPAN Release](https://badge.fury.io/pl/Type-Alias.svg)](https://metacpan.org/release/Type-Alias)
# NAME

Type::Alias - type alias for type constraints

# SYNOPSIS

```perl
use Type::Alias -declare => [qw(ID User List)];
use Types::Standard -types;

type ID => Str;

type User => {
    id   => ID,
    name => Str,
    age  => Int,
};

type List => sub($R) {
   $R ? ArrayRef[$R] : ArrayRef;
};

# =>
# ArrayRef[
#     Dict[
#         age=>Int,
#         id=>Str,
#         name=>Str
#     ]
# ]
```

# DESCRIPTION

Type::Alias creates type aliases for existing type constraints such as Type::Tiny, Moose. The aim of this module is to enhance the reusability of types and make it easier to express types.

## IMPORT OPTIONS

### -declare

`-declare` is an array reference that defines type aliases. The default is `[]`.

```perl
use Type::Alias -declare => [qw(ID User List)];
```

### -type\_alias

`-type_alias` is a function name that defines type aliases. The default name is **type**.

```perl
use Type::Alias -type_alias => 'mytype';

mytype ID => Str; # declare type alias
```

## EXPORTED FUNCTIONS

### type($alias\_name, $type\_alias\_args)

`type` is a function that defines type aliases. The default name is **type**.

Given a type constraint in `$type_alias_args`, it returns the type constraint as is.
Type::Alias treats objects with `check` and `get_message` methods as type constraints.

```perl
type ID => Str;
# sub ID(;$) { Str }
```

Given a hash reference in `$type_alias_args`, it returns the type constraint defined by Type::Tiny's Dict type.

```perl
type Point => {
    x => Int,
    y => Int,
};
# sub Point(;$) { Dict[x=>Int,y=>Int] }
```

Given an array reference in `$type_alias_args`, it returns the type constraint defined by Type::Tiny's Tuple type.

```perl
type Option => [Str, Int];
# sub Option(;$) { Tuple[Str,Int] }
```

Given a code reference in `$type_alias_args`, it defines a type function that accepts a type constraint as an argument and return the type constraint.

```perl
type List => sub($R) {
   $R ? ArrayRef[$R] : ArrayRef;
};
# sub List :prototype(;$) {
#   my $R = Type::Alias::to_type($_[0]);
#   $R ? ArrayRef[$R] : ArrayRef;
# }
```

Internally, it recursively generates Type::Tiny type constraints based on `$type_alias_args` using the Type::Alias::to\_type function.

# LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

kobaken <kfly@cpan.org>
