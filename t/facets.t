#!perl

use Test2::V0;

{
    package MyTypes;

    use Carp;
    use Type::Utils;
    use Type::Library -base,
      -declare => 'T1', 'T2';

    use B qw(perlstring);

    use Types::Standard -types, 'is_Num';

    use Type::TinyX::Facets;

    facet 'min',
      sub { my ( $o, $var ) = @_;
            return unless exists $o->{min};
            croak( "argument to 'min' facet must be a number\n" )
              unless is_Num( $o->{min} );
            sprintf('%s >= %s', $var, perlstring $o->{min} );
        };

    facet 'max',
      sub { my ( $o, $var ) = @_;
            return unless exists $o->{max};
            croak( "argument to 'max' facet must be a number\n" )
              unless is_Num( $o->{max} );
            sprintf('%s <= %s', $var, perlstring $o->{max} );
        };

    facetize qw[min max],
      declare T1, as Num;

    facetize qw[ min max ],
      positive => sub {  my ($o, $var) = @_;
                         return unless exists $o->{positive};
                         sprintf('%s > 0', $var);
                     },
      declare T2, as Num;
}


subtest 'T1' => sub {

    my $T1;
    ok(
       lives {
           $T1 = MyTypes::T1([ min => -3, max => 5 ]);
       }, 'construct T1 type with valid parameters'
      );

    ok( ! $T1->check( -3.1 ), 'too small' );
    ok( ! $T1->check( 5.1 ), 'too big' );
    ok( $T1->check( 0 ), 'just right' );

    ok(
       lives {
           $T1 = MyTypes::T1([ min => -3 ]);
       }, 'construct T1 type with single facet out of several'
      );

    like(
       dies {
           $T1 = MyTypes::T1([ positive => 1 ]);
       },
         qr/unrecogni[sz]ed parameter.*positive.*/,
         'construct T1 type with unknown parameter'
        );

    like(
       dies {
           $T1 = MyTypes::T1([ min => 'huh?' ]);
       },
         qr/must be a number/,
         'construct T1 type with illegal parameter value'
        );

};

subtest 'T2' => sub {
    my $T2;
    ok(
       lives {
           $T2 = MyTypes::T2([ min => -3, max => 5, positive => 1 ]);
       }, 'construct T2 type with valid parameters'
      );

    ok( ! $T2->check( -1 ), 'negative' );
    ok( ! $T2->check( 0 ), 'zero' );
    ok( ! $T2->check( 5.1 ), 'too big' );
    ok( $T2->check( 0.1 ), 'just right' );

};

done_testing;
