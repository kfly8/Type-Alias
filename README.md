[![Actions Status](https://github.com/kfly8/p5-Type-Alias/actions/workflows/test.yml/badge.svg)](https://github.com/kfly8/p5-Type-Alias/actions)
# NAME

Type::Alias - type alias for Type::Tiny

# SYNOPSIS

    use Type::Alias -declare => qw(ID User List Hoge);
    use Types::Standard -types;

    type ID => Str;

    type User => {
        id   => ID,
        name => Str,
        age  => Int,
    };

    type List => sub($R) {
        [$R]
    };

    type Hoge => List[User] | User;

    Hoge;
    # =>
    # ArrayRef[
    #     Dict[
    #         age=>Int,
    #         id=>Str,
    #         name=>Str
    #     ]
    # ]
    # |
    # Dict[
    #     age=>Int,
    #     id=>Str,
    #     name=>Str
    # ]

    our @EXPORT_OK; # => ID User List Hoge

# DESCRIPTION

Type::Alias is ...

# LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

kobaken <kentafly88@gmail.com>
