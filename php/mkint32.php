<?php
function mkint32($i) { $r = chr($i & 255); $i >>= 8; $r .= chr($i & 255); $i >>=8; $r .= chr($i & 255); $i >>=8; $r .= chr($i & 255); return $r; }
$handle = fopen( 'php://stdin', 'r' );
while( ! feof( $handle ) ) {
	$line = fgets( $handle );
	echo mkint32( trim( $line ) );
}
?>
