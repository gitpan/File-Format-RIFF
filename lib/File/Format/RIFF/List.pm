package File::Format::RIFF::List;
use base File::Format::RIFF::Container;


our $VERSION = '0.03';


sub new
{
   my ( $proto, $type, $data ) = @_;
   return $proto->SUPER::new( $type, 'LIST', $data );
}


sub read
{
   my ( $proto, $fh ) = @_;
   return $proto->SUPER::read( 'LIST', $fh );
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
