package File::Format::RIFF::Container;
use base File::Format::RIFF::Chunk;


use File::Format::RIFF::List;

our $VERSION = '0.01';


sub new
{
   my ( $proto, %args ) = @_;
   my ( $type, $fh );
   if ( exists $args{type} )
   {
      $type = $args{type};
      delete $args{type};
   }
   die "Cannot set data in Container constructor" if ( exists $args{data} );
   $fh = $args{fh} if ( exists $args{fh} );
   my ( $self ) = $proto->SUPER::new( %args );
   if ( defined $fh )
   {
      die "Cannot set type if fh is specified" if ( defined $type );
   } else {
      $self->type( $type );
   }
   return $self;
}


sub type
{
   my ( $self ) = shift;
   return return $self->{type} unless ( @_ );
   my ( $type ) = shift;
   die "Length of type must be 4" unless ( length( $type ) == 4 );
   $self->{type} = $type;
}


sub total_size
{
   my ( $self ) = @_;
   return $self->SUPER::total_size + 4;
}


sub data
{
   my ( $self ) = @_;
   return @{ $self->{data} };
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
   map { die "Can only add Chunk or List elements"
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


sub shift
{
   my ( $self ) = @_;
   return $self->splice( 0, 1 );
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
      die "Embedded RIFF chunks not allowed" if ( $id eq 'RIFF' );
      my ( $subchunk ) = ( $id eq 'LIST' )
         ? new File::Format::RIFF::List( fh => $fh )
         : new File::Format::RIFF::Chunk( id => $id, fh => $fh );
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


1;


=pod

=head1 NAME

File::Format::RIFF::Container - RIFF Container (LISTs and RIFFs)

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Paul Sturm E<lt>I<sturm@branewave.com>E<gt>

=cut
