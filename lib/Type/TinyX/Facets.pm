package Type::TinyX::Facets;

# ABSTRACT: Easily create a facet parameterized Type::Tiny type

use strict;
use warnings;

our $VERSION = '0.01';

use B qw(perlstring);
use Exporter 'import';
use Carp;
use Safe::Isa;
use Data::OptList;

our @EXPORT = qw'facet facetize';

my %FACET;

=sub facet( $name, $coderef )

Declare a facet with the given name and code generator. C<$coderef>
will be called as

  $coderef->( $options, $name );

where C<$options> is a hash of the parameters passed to the type, and
C<$name> is the name of the variable to check against.  The code
should return if the passed options are of no interest (and thus the
facet should not be applied), otherwise it should return a string
containing the validation code.  For example, to implement a minimum
value check:

  facet 'min',
    sub { my ( $o, $var ) = @_;
          return unless exists $o->{min};
          croak( "argument to 'min' facet must be a number\n" )
            unless is_Num( $o->{min} );
          sprintf('%s >= %s', $var, perlstring $o->{min} );
      };

=cut

sub facet {

    my ( $name, $coderef ) = @_;

    my $caller = caller;

    $FACET{$caller} ||= {};
    $FACET{$caller}{$name} = $coderef;
}

=sub facetize( @facets, $type )

Add the specified facets to the given type.  The type should not have
any constraints other than through inheritance from a parent type.

C<@facets> is a list of facets.  If a facet was previously created with the
L</facet> subroutine, only the name (as a string) need be specified. A facet
may also be specified as a name, coderef pair, e.g.

  @facets = (
      'min',
      positive => sub {  my ($o, $var) = @_;
                         return unless exists $o->{positive};
                         sprintf('%s > 0', $var);
                     }
  );

Typically B<facetize> is applied directly to a L<Type::Utils/declare>
statement, e.g.:

  facetize @facets,
    declare T1, as Num;

=cut


sub facetize {

    # type may be first or last parameter
    my $self
      = $_[-1]->$_isa( 'Type::Tiny' ) ? pop
      : croak( "type object must be last parameter\n" );

    my $FACET = $FACET{caller()};

    my @facets = map {
        my ( $facet, $sub ) = @{$_};
        $sub ||= $FACET->{$facet} || croak( "unknown facet: $facet" );
        [ $facet, $sub ];
    } @{ Data::OptList::mkopt( \@_ ) };


    my $name   = "$self";

    my $inline_generator = sub {
        my %p_not_destroyed = @_;
        return sub {
            my %p   = %p_not_destroyed;    # copy;
            my $var = $_[1];
            my $r   = sprintf(
                '(%s)',
                join( ' and ',
                    $self->inline_check( $var ),
                      map { my $code = $_->[1]->( \%p, $var );
                            delete $p{$_->[0]};
                            $code || ()
                        } @facets
                    ),
                );

            croak sprintf(
                'Attempt to parameterize type "%s" with unrecognised parameter%s %s',
                $name,
                scalar( keys %p ) == 1 ? '' : 's',
                join( ", ", map( qq["$_"], sort keys %p ) ),
            ) if keys %p;
            return $r;
        };
    };

    $self->{inline_generator}     = $inline_generator;
    $self->{constraint_generator} = sub {
        my $sub = sprintf( 'sub { %s }',
            $inline_generator->( @_ )->( $self, '$_[0]' ),
        );
        ## no critic( ProhibitStringyEval )
        eval( $sub ) or croak "could not build sub: $@\n\nCODE: $sub\n";
    };
    $self->{name_generator} = sub {
        my ( $s, %a ) = @_;
        sprintf( '%s[%s]',
            $s, join q[,],
            map sprintf( "%s=>%s", $_, perlstring $a{$_} ),
            sort keys %a );
    };

    return if $self->is_anon;

    ## no critic( ProhibitNoStrict )
    no strict qw( refs );
    no warnings qw( redefine prototype );
    *{ $self->library . '::' . $self->name } = $self->library->_mksub( $self );
}



1;

# COPYRIGHT

__END__


=head1 SYNOPSIS

# EXAMPLE: examples/MyTypes.pm

And in some other code:

# EXAMPLE: examples/synopsis_use.pl

results in

# COMMAND: perl -Ilib -Iexamples examples/synopsis_use.pl 2>&1 ; true

=head1 DESCRIPTION

B<Type::TinyX::Facets> make it easy to create parameterized types with facets.


=head1 THANKS

=over

=item L<TOBYINK|https://metacpan.org/author/TOBYINK> The idea and most of the code was lifted from L<Types::XSD::Lite>.

=back

=head1 SEE ALSO
