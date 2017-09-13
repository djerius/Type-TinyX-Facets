#!perl

use Test2::V0;
use Test::Lib;

use My::Types -types;

subtest 'MinMax' => sub {

    my $type;
    ok(
       lives {
           $type = MinMax([ min => -3, max => 5 ]);
       }, 'construct MinMax type with valid parameters'
      );

    ok( ! $type->check( -3.1 ), 'too small' );
    ok( ! $type->check( 5.1 ), 'too big' );
    ok( $type->check( 0 ), 'just right' );

    ok(
       lives {
           $type = MinMax([ min => -3 ]);
       }, 'construct MinMax type with single facet out of several'
      );

    like(
       dies {
           $type = MinMax([ positive => 1 ]);
       },
         qr/unrecogni[sz]ed parameter.*positive.*/,
         'construct MinMax type with unknown parameter'
        );

    like(
       dies {
           $type = MinMax([ min => 'huh?' ]);
       },
         qr/must be a number/,
         'construct MinMax type with illegal parameter value'
        );

};

subtest 'Positive' => sub {
    my $type;
    ok(
       lives {
           $type = Positive([ min => -3, max => 5, positive => 1 ]);
       }, 'construct Positive type with valid parameters'
      );

    ok( ! $type->check( -1 ), 'negative' );
    ok( ! $type->check( 0 ), 'zero' );
    ok( ! $type->check( 5.1 ), 'too big' );
    ok( $type->check( 0.1 ), 'just right' );

};

done_testing;
