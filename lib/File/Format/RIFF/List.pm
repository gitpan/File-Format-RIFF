package File::Format::RIFF::List;
use base File::Format::RIFF::Container;


our $VERSION = '0.02';


use Carp;


sub new
{
   my ( $proto, %args ) = @_;
   croak "Cannot set id of LIST chunk" if ( exists $args{id} );
   return $proto->SUPER::new( %args, id => 'LIST' );
}


1;


=pod

=head1 NAME

File::Format::RIFF::List - RIFF LIST

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Paul Sturm E<lt>I<sturm@branewave.com>E<gt>

=cut
