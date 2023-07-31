package Type::Alias;
use strict;
use warnings;

our $VERSION = "0.03";

use feature qw(state);
use Carp qw(croak);
use Scalar::Util qw(blessed);
use Types::Standard qw(Dict Tuple);

sub import {
    my ($class, %args) = @_;

    my $target_package = caller;

    $class->_define_type($target_package, $args{type});
    $class->_predefine_type_aliases($target_package, $args{'-alias'});
    $class->_predefine_type_functions($target_package, $args{'-fun'});
}

sub _define_type {
    my ($class, $target_package, $options) = @_;
    $options //= {};
    my $type_name = $options->{'-as'} // 'type';

    if ($target_package->can($type_name)) {
        croak "Alreay exists function '${target_package}::${type_name}'. Can specify another name: type => { -as => 'XXX' }.";
    }

    no strict qw(refs);
    no warnings qw(once);
    *{"${target_package}::${type_name}"} = sub {
        my ($alias_name, $type_args) = @_;

        no strict qw(refs);
        no warnings qw(redefine); # Already define empty type alias at _import_type_aliases
        *{"${target_package}::${alias_name}"} = generate_type_alias($type_args);
    }
}

sub _predefine_type_aliases {
    my ($class, $target_package, $type_aliases) = @_;
    $type_aliases //= [];

    for my $alias_name (@$type_aliases) {
        if ($target_package->can($alias_name)) {
            croak "Cannot predeclare type alias '${target_package}::${alias_name}'.";
        }

        no strict qw(refs);
        *{"${target_package}::${alias_name}"} = sub :prototype() {
            croak "You should define type alias '$alias_name' before using it."
        }
    }
}

sub _predefine_type_functions {
    my ($class, $target_package, $type_functions) = @_;
    $type_functions //= [];

    for my $type_function (@$type_functions) {
        if ($target_package->can($type_function)) {
            croak "Cannot predeclare type function '${target_package}::${type_function}'.";
        }

        no strict qw(refs);
        *{"${target_package}::${type_function}"} = sub :prototype(;$) {
            croak "You should define type function '$type_function' before using it."
        }
    }
}

sub to_type {
    my $v = shift;
    if (blessed($v)) {
        if ($v->can('check') && $v->can('get_message')) {
            return $v;
        }
        else {
            croak 'This object is not supported: '. ref $v;
        }
    }
    elsif (ref $v) {
        if (ref $v eq 'ARRAY') {
            return Tuple[ map { to_type($_) } @$v ];
        }
        elsif (ref $v eq 'HASH') {
            return Dict[
                map { $_ => to_type($v->{$_}) } sort { $a cmp $b } keys %$v
            ];
        }
        elsif (ref $v eq 'CODE') {
            return sub {
                my @args;
                if (@_) {
                    unless (@_ == 1 && ref $_[0] eq 'ARRAY') {
                        croak 'This type requires an array reference';
                    }
                    @args = map { to_type($_) } @{$_[0]};
                }

                to_type($v->(@args));
            }
        }
        else {
            croak 'This reference is not supported: ' . ref $v ;
        }
    }
    else {
        # TODO: Is it better to make it a type that checks whether it matches the given value?
        croak 'This value is not supported: ' . (defined $v ? $v : 'undef');
    }
}

sub generate_type_alias {
    my ($type_args) = @_;

    if ( (ref $type_args||'') eq 'CODE') {
        return sub :prototype(;$) {
            state $type = to_type($type_args);
            $type->(@_);
        };
    }
    else {
        return sub :prototype() {
            state $type = to_type($type_args);
            $type;
        }
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Type::Alias - type alias for type constraints

=head1 SYNOPSIS

    use Type::Alias -alias => [qw(ID User)], -fun => [qw(List)];
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

=head1 DESCRIPTION

Type::Alias creates type aliases for existing type constraints such as Type::Tiny, Moose. The aim of this module is to enhance the reusability of types and make it easier to express types.

=head2 IMPORT OPTIONS

=head3 -alias

C<-alias> is an array reference that defines type aliases. The default is C<[]>.

    use Type::Alias -alias => [qw(ID User)];

    type ID => Str;

    type User => {
        id   => ID,
        name => Str,
        age  => Int,
    };

=head3 -fun

C<-fun> is an array reference that defines type functions. The default is C<[]>.

    use Type::Alias -fun => [qw(List)];

    type List => sub($R) {
       $R ? ArrayRef[$R] : ArrayRef;
    };

=head3 type

The C<type> option is used to configure the type function that defines type aliases and type functions.

    # Rename type function:
    use Type::Alias type => { -as => 'mytype' };

    mytype ID => Str; # declare type alias

=head2 EXPORTED FUNCTIONS

=head3 type($alias_name, $type_alias_args)

C<type> is a function that defines type aliases. The default name is B<type>.

Given a type constraint in C<$type_alias_args>, it returns the type constraint as is.
Type::Alias treats objects with C<check> and C<get_message> methods as type constraints.

    type ID => Str;
    # sub ID() { Str }

Given a hash reference in C<$type_alias_args>, it returns the type constraint defined by Type::Tiny's Dict type.

    type Point => {
        x => Int,
        y => Int,
    };
    # sub Point() { Dict[x=>Int,y=>Int] }

Given an array reference in C<$type_alias_args>, it returns the type constraint defined by Type::Tiny's Tuple type.

    type Option => [Str, Int];
    # sub Option() { Tuple[Str,Int] }

Given a code reference in C<$type_alias_args>, it defines a type function that accepts a type constraint as an argument and return the type constraint.

    type List => sub($R) {
       $R ? ArrayRef[$R] : ArrayRef;
    };
    # sub List :prototype(;$) {
    #   my $R = Type::Alias::to_type($_[0]);
    #   $R ? ArrayRef[$R] : ArrayRef;
    # }

Internally, it recursively generates Type::Tiny type constraints based on C<$type_alias_args> using the Type::Alias::to_type function.

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kfly@cpan.orgE<gt>

=cut

