use Test;
BEGIN { plan tests => 3 };
use File::Format::RIFF;

open( IN, 't/test.riff' ) or die "could not open file";
my ( $riff1 ) = File::Format::RIFF->read( \*IN );
close( IN );
my ( $chnk ) = grep { $_->id eq 'chnk' } $riff1->data;
ok( $chnk->data, 'abcabc' );

my ( $riff2 ) = new File::Format::RIFF;
$riff2->type( 'TEST' );
$riff2->addChunk( chnk => 'abcabc' );

my ( $str1 ) = '';
open( STR, '>', \$str1 );
$riff1->write( \*STR );
close( STR );
ok( $str1 );
my ( $str2 ) = '';
open( STR, '>', \$str2 );
$riff2->write( \*STR );
close( STR );
ok( $str1, $str2 );
