use Test;
BEGIN { plan tests => 2 };
use File::Format::RIFF;
ok( 1 );

open( IN, 't/test.riff' ) or die "could not open file";
my ( $riff ) =  new File::Format::RIFF( fh => \*IN );
close( IN );
my ( $chnk ) = grep { $_->id eq 'chnk' } $riff->data;
( $chnk->data eq 'abcabc' ) ? ok( 2 ) : nok( 2 );
