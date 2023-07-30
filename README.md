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

Type::Alias creates type aliases for existing type constraints such as Type::Tiny and Mo(o|u)se. The aim of this module is to enhance the reusability of types and make it easier to express types.

## OPTIONS

### -declare

`-declare` is an array reference that defines type aliases. The default is \[\].

```perl
use Type::Alias -declare => [qw(ID User List)];
```

### -type\_alias

`-type_alias` is a function name that defines type aliases. The default is 'type'.

```perl
use Type::Alias -type_alias => 'mytype';

mytype ID => Str; # declare type alias
```

### -export\_ok

`-export_ok` is an array reference that defines type aliases to be exported. The default is all type aliases defined by `-declare`.

```perl
Default case:
use Type::Alias -declare => [qw(ID User List];
our @EXPORT_OK;

# => @EXPORT_OK = qw(ID User List);

Specify export_ok:
use Type::Alias -declare => [qw(ID User List], -export_ok => [qw(List)];
our @EXPORT_OK;

# => @EXPORT_OK = qw(List);
```

# LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

kobaken <kfly@cpan.org>
