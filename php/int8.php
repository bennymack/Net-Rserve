<?php
function int8($buf, $o=0) { return ord($buf[$o]); }
#function int8($buf, $o=0) { return ord( substr( $buf, $o, 1 ) ); }
$handle = fopen( 'php://stdin', 'r' );
while( ! feof( $handle ) ) {
	$line = fgets( $handle );
	echo int8( trim( $line ) );
}
?>
