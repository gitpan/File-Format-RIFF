package File::Format::RIFF;
use base File::Format::RIFF::Container;


use 5.006;
use Carp;

our $VERSION = '0.07';


sub new
{
   my ( $proto, $type, $data ) = @_;
   return $proto->SUPER::new( $type, 'RIFF', $data );
}


sub read
{
   my ( $proto ) = shift;
   my ( $fh ) = shift;

   my ( $filesize );
   if ( @_ )
   {
      $filesize = @_;
      $filesize = 0+$filesize if ( defined $filesize );
   } else {
      $filesize = ( stat( $fh ) )[ 7 ];
   }
   croak 'Bad file: too small' if ( defined $filesize and $filesize < 12 );

   my ( $id ) = $proto->_read_fourcc( $fh );
   croak "Bad file ($id)" unless ( $id eq 'RIFF' );

   my ( $self ) = $proto->SUPER::read( 'RIFF', $fh );

   croak "Bad file: expected $filesize bytes, got " . $self->total_size
      if ( defined $filesize and $filesize != $self->total_size );

   return $self;
}


1;


=pod

=head1 NAME

File::Format::RIFF - Resource Interchange File Format/RIFF files

=head1 SYNOPSIS

   use File::Format::RIFF;

   open( IN, 'file' ) or die "Could not open file: $!";
   my ( $riff1 ) = File::Format::RIFF->read( \*IN );
   close( IN );
   $riff1->dump;

   my ( $riff2 ) = new File::Format::RIFF( 'TYPE' );
   foreach my $chunk ( $riff1->data )
   {
      next if ( $chunk->id eq 'LIST' );
      $riff2->addChunk( $chunk->id, $chunk->data );
   }
   open( OUT, ">otherfile" ) or die "Could not open file: $!";
   $riff2->write( \*OUT );
   close( OUT );

=head1 DESCRIPTION

C<File::Format::RIFF> provides an implementation of the Resource Interchange
File Format.  You can read, manipulate, and write RIFF files.

=head1 CONSTRUCTORS

=over 4

=item my ( $riff ) = new File::Format::RIFF( $type, $data );

Creates a new File::Format::RIFF object.  C<$type> is a four character code
that identifies the type of this particular RIFF file.  Certain types are
defined to have a format, specifying which chunks must appear (e.g., WAVE
files).  If C<$type> is not specified, it defaults to '    '.  C<$data> must
be an array reference containing some number of RIFF lists and/or RIFF
chunks.  If C<$data> is C<undef> or not specified, then the new RIFF object
is initialized empty.

=item my ( $riff ) = File::Format::RIFF->read( $fh, $filesize );

Reads and parses an existing RIFF file from the given filehandle C<$fh>.  An
exception will be thrown if the file is not a valid RIFF file.  C<$filesize>
controls on aspect of the file format checking -- if C<$filesize> is not
specified, then C<stat> will be called on C<$fh> to determine how much data
to expect.  You may explicitly specify how much data to expect by passing
in that value as C<$filesize>.  In either case, the amount of data read will
be checked to make sure it matches the amount expected.  Otherwise, it will
throw an exception.  If you do not wish it to make this check, pass in C<undef>
for C<$filesize>.

Please note, if you wish to read an "in memory" filehandle, such as by doing
this: C<open( $fh, '>', \$variable )>, you may do so, but you must pass in
C<length( $variable )> for C<$filesize>, because filehandles opened this way
to do not support the C<stat> call.

You may also use sockets for C<$fh>.  But if you do, you must either specify
the amount of data expected by passing in a value for C<$filesize>, or you
must pass in C<undef> for C<$filesize> if you do not know ahead of time how
much data to expect.

=back

=head1 SEE ALSO

=over 4

=item L<File::Format::RIFF::Container>

C<File::Format::RIFF> inherits from C<File::Format::RIFF::Container>, so all
methods available for Containers can be used on RIFF objects.  A Container
essentially contains an array of RIFF lists and/or RIFF chunks.  See
the L<File::Format::RIFF::Container> man page for more information.

=back

=head1 AUTHOR

Paul Sturm E<lt>I<sturm@branewave.com>E<gt>

=head1 WEBSITE

L<http://branewave.com/perl>

=head1 COPYRIGHT

Copyright (c) 2005 Paul Sturm.  All rights reserved.  This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

I would love to hear about my software being used; send me an email!

=cut