package My::Types;

use Carp;
use Type::Utils;
use Type::Library -base,
  -declare => 'MinMax', 'Positive';

use Types::Standard -types, 'is_Num';

use Type::TinyX::Facets;

facet 'min', sub {
    my ( $o, $var ) = @_;
    return unless exists $o->{min};
    croak( "argument to 'min' facet must be a number\n" )
      unless is_Num( $o->{min} );
    sprintf( '%s >= %s', $var, $o->{min} );
};

facet 'max', sub {
    my ( $o, $var ) = @_;
    return unless exists $o->{max};
    croak( "argument to 'max' facet must be a number\n" )
      unless is_Num( $o->{max} );
    sprintf( '%s <= %s', $var, $o->{max} );
};

facetize qw[min max], declare MinMax, as Num;

# on-the-fly creation of a facet
facetize positive => sub {
    my ( $o, $var ) = @_;
    return unless exists $o->{positive};
    delete $o->{positive};
    sprintf( '%s > 0', $var );
  },
  qw[ min max ],
  declare Positive, as Num;

1;
