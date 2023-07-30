package Type::Alias;
use strict;
use warnings;

our $VERSION = "0.01";

use feature qw(state);
use Carp qw(croak);
use Scalar::Util qw(blessed);
use Types::Standard qw(ArrayRef Dict Tuple);
use B::Hooks::EndOfScope qw(on_scope_end);

sub import {
    my ($class, %args) = @_;

    my $target_package = caller;

    # define type alias function
    my $type_alias_function_name = $args{'-type_alias'} // 'type';
    $class->_import_type_alias_function($target_package, $type_alias_function_name);

    # predefine type aliases
    my $type_aliases = $args{'-declare'} // [];
    $class->_import_type_aliases($target_package, $type_aliases);

    # push @EXPORT_OK => @type_aliases
    if ($args{'-export_ok'}) {
        for my $export (@{ $args{'-export_ok'} }) {
            unless (grep { $_ eq $export } @$type_aliases) {
                croak "Type alias '$export' is not declared. should fix -declare or -export_ok.";
            }
        }
    }
    my $export_ok = $args{'-export_ok'} // $type_aliases;
    on_scope_end {
        $class->_import_export_ok($target_package, $export_ok);
    }
}

sub _import_type_alias_function {
    my ($class, $target_package, $type_alias_function_name) = @_;

    if ($target_package->can($type_alias_function_name)) {
        croak "Alreay exists function '${target_package}::${type_alias_function_name}'. Please use another type alias function name.";
    }

    no strict qw(refs);
    no warnings qw(once);
    *{"${target_package}::${type_alias_function_name}"} = sub {
        my ($type_alias_name, $type_alias_args) = @_;

        no strict qw(refs);
        no warnings qw(redefine); # Already define empty type alias at _import_type_aliases
        *{"${target_package}::${type_alias_name}"} = generate_type_alias($type_alias_args);
    }
}

sub _import_type_aliases {
    my ($class, $target_package, $type_aliases) = @_;

    for my $type_alias (@$type_aliases) {
        if ($target_package->can($type_alias)) {
            croak "Cannot predeclare type alias '${target_package}::${type_alias}'.";
        }

        no strict qw(refs);
        *{"${target_package}::${type_alias}"} = sub :prototype(;$) {
            croak "You should define type alias '$type_alias' before using it."
        }
    }
}

sub _import_export_ok {
    my ($class, $target_package, $export_ok) = @_;

    no strict qw(refs);
    if (defined *{"${target_package}::EXPORT_OK"}{ARRAY}) {
        push @{"${target_package}::EXPORT_OK"}, @$export_ok;
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
    my ($type_alias_args) = @_;

    return sub :prototype(;$) {
        state $type = to_type($type_alias_args);

        if (@_) {
            unless (ref $type eq 'CODE') {
                croak 'This type does not accept parameters';
            }
            return $type->(@_);
        }
        else {
            return $type;
        }
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Type::Alias - type alias for type constraints

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Type::Alias creates type aliases for existing type constraints such as Type::Tiny and Mo(o|u)se. The aim of this module is to enhance the reusability of types and make it easier to express types.

=head2 OPTIONS

=head3 -declare

C<-declare> is an array reference that defines type aliases. The default is [].

    use Type::Alias -declare => [qw(ID User List)];


=head3 -type_alias

C<-type_alias> is a function name that defines type aliases. The default is 'type'.

    use Type::Alias -type_alias => 'mytype';

    mytype ID => Str; # declare type alias


=head3 -export_ok

C<-export_ok> is an array reference that defines type aliases to be exported. The default is all type aliases defined by C<-declare>.

    # Default case:
    use Type::Alias -declare => [qw(ID User List];
    our @EXPORT_OK; # => qw(ID User List);

    # Specify export_ok:
    use Type::Alias -declare => [qw(ID User List], -export_ok => [qw(List)];
    our @EXPORT_OK; # => qw(List);

=head1 LICENSE

Copyright (C) kobaken.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

kobaken E<lt>kfly@cpan.orgE<gt>

=cut

