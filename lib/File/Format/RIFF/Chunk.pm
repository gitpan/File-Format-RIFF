package File::Format::RIFF::Chunk;


use bytes;

our $VERSION = '0.02';


use vars qw/ $PACKFMT /;
BEGIN { $PACKFMT = 'V' }

our ( @params ) = qw/ id fh data /;

sub new
{
   my ( $proto, %args ) = @_;
   my ( $class ) = ref( $proto ) || $proto;

   $args{id} = '    ' unless ( exists $args{id} );
   my ( $id, $fh, $data ) = @args{ @params };
   delete @args{ @params };
   die "Extraneous args passed to constructor" if ( keys %args );

   my ( $self ) = bless { }, $class;
   $self->id( $id );
   if ( defined $fh )
   {
      die "Cannot set data if fh is specified" if ( defined $data );
      $self->_read_header( $fh );
      $self->_read_data( $fh );
   } else {
      $self->data( $data );
   }
   return $self;
}


sub write
{
   my ( $self, $fh ) = @_;
   $self->_write_header( $fh );
   $self->_write_data( $fh );
}


sub id
{
   my ( $self ) = shift;
   return $self->{id} unless ( @_ );
   my ( $id ) = shift;
   die "Length of id must be 4" unless ( length( $id ) == 4 );
   $self->{id} = $id;
}


sub data
{
   my ( $self ) = shift;
   return $self->{data} unless ( @_ );
   $self->{size} = length( $self->{data} = shift );
}


sub size
{
   my ( $self ) = @_;
   return $self->{size};
}


sub total_size
{
   my ( $self ) = @_;
   my ( $sz ) = $self->size;
   return 8 + $sz + ( $sz % 2 );
}


sub _read_header
{
   my ( $self, $fh ) = @_;
   $self->{size} = $self->_read_size( $fh );
}


sub _write_header
{
   my ( $self, $fh ) = @_;
   $self->_write_fourcc( $fh, $self->{id} );
   $self->_write_size( $fh, $self->{size} );
}


sub _read_data
{
   my ( $self, $fh ) = @_;
   my ( $sz ) = $self->size;
   $self->_file_read( $fh, \$self->{data}, $sz );
   return unless ( $sz % 2 );

   my ( $x );
   $self->_file_read( $fh, \$x, 1 );
}


sub _write_data
{
   my ( $self, $fh ) = @_;
   $self->_file_write( $fh, $self->{data} );
   $self->_file_write( $fh, "\0" ) if ( $self->{size} % 2 );
}


sub _file_read
{
   my ( $proto, $fh, $ref, $expect ) = @_;
   my ( $got ) = read( $fh, $$ref, $expect );
   die "File read error: $!" unless ( defined $got );
   die "File read error: got fewer bytes than expected ($got of $expect)"
      unless ( $got == $expect );
}


sub _file_write
{
   my ( $proto, $fh, @data ) = @_;
   print { $fh } @data or die 'Could not write to file';
}


sub _read_fourcc
{
   my ( $proto, $fh ) = @_;
   my ( $fourcc );
   $proto->_file_read( $fh, \$fourcc, 4 );
   return $fourcc;
}


sub _write_fourcc
{
   my ( $self, $fh, $fourcc ) = @_;
   $self->_file_write( $fh, $fourcc );
}


sub _read_size
{
   my ( $proto, $fh ) = @_;
   my ( $size );
   $proto->_file_read( $fh, \$size, 4 );
   return unpack( $PACKFMT, $size );
}


sub _write_size
{
   my ( $self, $fh, $size ) = @_;
   $self->_file_write( $fh, pack( $PACKFMT, $size ) );
}


sub dump
{
   my ( $self, $max, $indent ) = @_;
   $max = 64 unless ( defined $max );
   $indent = 0 unless ( defined $indent and $indent > 0 );
   print join( '', "\t" x $indent ), 'id: ', $self->id,
      ' size: ', $self->size, ' (', $self->total_size, '): ';
   ( $max and $self->size > $max ) ? print '[...]' : print $self->{data};
   print "\n";
}


1;


=pod

=head1 NAME

File::Format::RIFF::Chunk - RIFF Chunk

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Paul Sturm E<lt>I<sturm@branewave.com>E<gt>

=cut
