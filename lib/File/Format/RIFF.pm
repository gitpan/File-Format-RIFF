package File::Format::RIFF;
use base File::Format::RIFF::Container;


use 5.006;
use Carp;

our $VERSION = '0.06';


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

=head1 DESCRIPTION

C<File::Format::RIFF> provides an implementation of the Resource Interchange
File Format.  You can read, manipulate, and write RIFF files.

=head1 SEE ALSO

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
