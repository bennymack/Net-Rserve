<?php
function int24($buf, $o=0) { return( ord( substr( $buf, $o, 1 ) ) | (ord( substr( $buf, $o + 1, 1 )) << 8) | (ord( substr( $buf, $o + 2, 1 ) ) << 16) ); }
#function int24($buf, $o=0) { return (ord($buf[$o]) | (ord($buf[$o + 1]) << 8) | (ord($buf[$o + 2]) << 16)); }
$handle = fopen( 'php://stdin', 'r' );
while( ! feof( $handle ) ) {
	$line = fgets( $handle );
	echo int24( trim( $line ) );
}
?>
