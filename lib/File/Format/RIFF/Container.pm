package File::Format::RIFF::Container;
use base File::Format::RIFF::Chunk;


our $VERSION = '0.03';


use Carp;
use File::Format::RIFF::List;


sub new
{
   my ( $proto, $type, $id, $data ) = @_;
   my ( $self ) = $proto->SUPER::new( $id, $data );
   $self->type( defined $type ? $type : '    ' );
   return $self;
}


sub type
{
   my ( $self ) = shift;
   return $self->{type} unless ( @_ );
   my ( $type ) = shift;
   croak "Length of type must be 4" unless ( length( $type ) == 4 );
   $self->{type} = $type;
}


sub id
{
   my ( $self ) = shift;
   croak "Cannot set id of $self->{id} chunk" if ( @_ and exists $self->{id} );
   return $self->SUPER::id( @_ );
}


sub total_size
{
   my ( $self ) = @_;
   return $self->SUPER::total_size + 4;
}


sub data
{
   my ( $self ) = shift;
   return @{ $self->{data} } unless ( @_ );
   my ( $data ) = @_;
   $data = [ ] unless ( defined $data and ref( $data ) eq 'ARRAY' );
   $self->{data} = [ ];
   $self->push( @$data );
}


sub numChunks
{
   my ( $self ) = @_;
   return scalar( @{ $self->{data} } );
}


sub size
{
   my ( $self ) = @_;
   my ( $sz ) = 0;
   map { $sz += $_->total_size } @{ $self->{data} };
   return $sz;
}


sub splice
{
   my ( $self, $offset, $length, @elts ) = @_;
   map { croak "Can only add Chunk or List elements"
      unless ( ref( $_ ) and $_->isa( 'File::Format::RIFF::Chunk' ) ) } @elts;
   return ( @_ > 3 )
      ? splice( @{ $self->{data} }, $offset, $length, @elts )
      : ( @_ == 3 )
         ? splice( @{ $self->{data} }, $offset, $length )
         : ( @_ == 2 )
            ? splice( @{ $self->{data} }, $offset )
            : splice( @{ $self->{data} } );
}


sub push
{
   my ( $self, @elts ) = @_;
   return $self->splice( scalar( @{ $self->{data} } ), 0, @elts );
}


sub pop
{
   my ( $self ) = @_;
   return $self->splice( -1 );
}


sub unshift
{
   my ( $self, @elts ) = @_;
   return $self->splice( 0, 0, @elts );
}


sub at
{
   my ( $self, $i ) = @_[ 0 .. 1 ];
   return $self->splice( $i, 1, $_[ 0 ] ) if ( @_ );
   return $self->{data}->[ $i ];
}


sub addChunk
{
   my ( $self ) = shift;
   my ( $chk ) = new File::Format::RIFF::Chunk( @_ );
   $self->push( $chk );
   return $chk;
}


sub addList
{
   my ( $self ) = shift;
   my ( $ctr ) = new File::Format::RIFF::List( @_ );
   $self->push( $ctr );
   return $ctr;
}


sub _read_header
{
   my ( $self, $fh ) = @_;
   $self->SUPER::_read_header( $fh );
   $self->{size} -= 4;
   $self->{type} = $self->_read_fourcc( $fh );
}


sub _write_header
{
   my ( $self, $fh ) = @_;
   $self->_write_fourcc( $fh, $self->{id} );
   $self->_write_size( $fh, $self->size + 4 );
   $self->_write_fourcc( $fh, $self->{type} );
}


sub _read_data
{
   my ( $self, $fh ) = @_;
   my ( $to_read ) = $self->{size};
   $self->{data} = [ ];
   while ( $to_read )
   {
      my ( $id ) = $self->_read_fourcc( $fh );
      croak "Embedded RIFF chunks not allowed" if ( $id eq 'RIFF' );
      my ( $subchunk ) = ( $id eq 'LIST' )
         ? File::Format::RIFF::List->read( $fh )
         : File::Format::RIFF::Chunk->read( $id, $fh );
      $to_read -= $subchunk->total_size;
      $self->push( $subchunk );
   }
}


sub _write_data
{
   my ( $self, $fh ) = @_;
   map { $_->write( $fh ) } @{ $self->{data} };
}


sub dump
{
   my ( $self, $max, $indent ) = @_;
   $max = 64 unless ( defined $max );
   $indent = 0 unless ( defined $indent and $indent > 0 );
   print join( '', "\t" x $indent ), 'id: ', $self->id, ' (',
      $self->type, ') size: ', $self->size, ' (', $self->total_size, ")\n";

   ++ $indent;
   map { $_->dump( $max, $indent ) } @{ $self->{data} };
}


sub shift
{
   my ( $self ) = @_;
   return $self->splice( 0, 1 );
}


1;


=pod

=head1 NAME

File::Format::RIFF::Container - RIFF Container (LISTs and RIFFs)

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Paul Sturm E<lt>I<sturm@branewave.com>E<gt>

=cut
