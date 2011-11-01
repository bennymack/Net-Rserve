<?php
function mkint24($i) { $r = chr($i & 255); $i >>= 8; $r .= chr($i & 255); $i >>=8; $r .= chr($i & 255); return $r; }
#echo mkint24( $argv[ 1 ] );
$handle = fopen( 'php://stdin', 'r' );
while( ! feof( $handle ) ) {
	$line = fgets( $handle );
	echo mkint24( trim( $line ) );
}
?>
