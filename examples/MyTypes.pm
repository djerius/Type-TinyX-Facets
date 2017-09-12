package MyTypes;

use Carp;
use Type::Utils;
use Type::Library -base,
  -declare => 'T1',
  'T2';

use B qw(perlstring);

use Types::Standard -types, 'is_Num';

use Type::TinyX::Facets;

facet 'min', sub {
    my ( $o, $var ) = @_;
    return unless exists $o->{min};
    croak( "argument to 'min' facet must be a number\n" )
      unless is_Num( $o->{min} );
    sprintf( '%s >= %s', $var, perlstring $o->{min} );
};

facetize qw[min], declare T1, as Num;

facetize positive => sub {
    my ( $o, $var ) = @_;
    return unless exists $o->{positive};
    sprintf( '%s > 0', $var );
  },
  declare T2, as Num;

1;
