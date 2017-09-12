use MyTypes -types;
use Type::Params qw[ validate ];

validate( [ 5 ], T1[min => 2] );      # passes

validate( [ 0 ], T2[positive => 1] ); # fails!


1;
