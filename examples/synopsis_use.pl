use My::Types -types;
use Type::Params qw[ validate ];

validate( [ 5 ], MinMax[min => 2] );            # passes
validate( [ 5 ], MinMax[min => 2, max => 6] );  # passes

validate( [ 0 ], Positive[positive => 1] );     # fails!
validate( [ 0 ], Positive[positive => 1] );     # fails!

