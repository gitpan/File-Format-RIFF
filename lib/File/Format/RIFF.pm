package File::Format::RIFF;
use base File::Format::RIFF::Container;


use 5.006;
use strict;
use warnings;

our $VERSION = '0.02';


sub new
{
   my ( $proto, %args ) = @_;
   die "Cannot set id of RIFF chunk" if ( exists $args{id} );
   if ( exists $args{fh} and defined $args{fh} )
   {
      my ( $id ) = $proto->_read_fourcc( $args{fh} );
      die "Bad file ($id)" unless ( $id eq 'RIFF' );
   }
   return $proto->SUPER::new( %args, id => 'RIFF' );
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

http://www.branewave.com/perl

=head1 COPYRIGHT

Copyright (c) 2005 Paul Sturm.  All rights reserved.  This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

I would love to hear about my software being used; send me an email!

=cut
