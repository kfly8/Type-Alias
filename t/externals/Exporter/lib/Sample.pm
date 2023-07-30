package Sample;
use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw( hello );
use Type::Alias -declare => [qw( Foo )];
use Types::Standard -types;

sub hello { "HELLO" }
type Foo => Str;

1;
