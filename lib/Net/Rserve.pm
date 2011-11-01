package Net::Rserve;
use strict;
use warnings;
use Rsrv();
use Data::Dumper;
use IO::Socket::INET;
use Time::HiRes qw(time);
use English qw(-no_match_vars);

__PACKAGE__->run if not caller;

sub run {
	my( $class ) = @ARG;

	my $self = bless {}, $class;

	$self->{socket} = IO::Socket::INET->new(
		PeerAddr => '127.0.0.1:6311',
		Type     => SOCK_STREAM,
		Blocking => 1,
	) or die 'Error connection - ', $OS_ERROR;

	do {
		my $read = sysread $self->{socket}, my $buffer, 4096;
		die sprintf 'invalid header? %d != 32', $read if 32 != $read;
		warn '$buffer = ', $buffer;
		$self->{rserve_id_signature} = substr $buffer, 0, 4;
		$self->{rserve_version_protocol} = substr $buffer, 4, 4;
		$self->{rserve_communication_protocol} = substr $buffer, 8, 4;
	};

	warn '$self = ', Dumper( $self );

	my $command = '0.1 + 0.2';
	my $packet  = $self->make_packet_string( Rsrv::CMD_eval, $command );
	syswrite $self->{socket}, $packet;

	my $response = $self->get_response;
	my $status = $self->unpack_32bit_int( substr $response, 0, 4 );
	my $status_code = ( $status >> 24 ) & 127;
	my $response_command = $status & 255;
	if( $response_command != 1 ) {
		die 'eval failed with error code ', $status_code;
	}

	if( $self->unpack_8bit_int( substr $response, 16, 1 ) != 10 ) {
		die 'invalid response (expecting SEXP)';
	}

#	my $i = 20;

	warn 'parse_sexp = ', Dumper( $self->parse_sexp( $response, 20, [] ) );

}

sub make_packet_string {
	my( $self, $command_num, $command_string ) = @ARG; 
	$command_string .= chr( 0 );
	my $length = length $command_string;

    while( $length % 4 ) {
		$command_string .= chr( 1 );
		$length++;
	}

    my $packet = pack( 'L', $command_num ) . pack( 'L', $length + 4 ) . pack( 'LL', 0, 0 ) . chr( 4 ) . $self->pack_24bit_int( $length ) . $command_string;
	return $packet;
}

sub unpack_8bit_int {
	my( $self, $num ) = @ARG;
	warn '$num should be length 1' if 1 != length $num;
	my $unpacked_8bit_int = unpack 'C', $num;
	return $unpacked_8bit_int;
}

# What if $num > 16777215/0xffffff ?
# Slightly wasteful yet succint implementation.
sub pack_24bit_int {
	my( $self, $num ) = @ARG;
	my $packed_32bit_int = pack 'L', $num;
	my $packed_24bit_int = substr $packed_32bit_int, 0, 3;
	return $packed_24bit_int;
}

sub unpack_24bit_int {
	my( $self, $num ) = @ARG;
	warn '$num should be length 3' if 3 != length $num;
	$num = $num . "\0";
	my $unpacked_32bit_int = unpack 'L', $num;
	my $unpacked_24bit_int = substr $unpacked_32bit_int, 0, 3;
	return $unpacked_24bit_int;
}

sub pack_32bit_int {
	my( $self, $num ) = @ARG;
	my $packed_32bit_int = pack 'L', $num;
	return $packed_32bit_int;
}

sub unpack_32bit_int {
	my( $self, $num ) = @ARG;
	warn '$num should be length 4' if 4 != length $num;
	my $unpacked_32bit_int = unpack 'L', $num;
	return $unpacked_32bit_int;
}

sub unpack_64bit_float {
	my( $self, $num ) = @ARG;
	warn '$num should be length 8' if 8 != length $num;
	my $unpacked_64bit_float = unpack 'd', $num;
	return $unpacked_64bit_float;
}

sub get_response {
	my( $self ) = @ARG;
	sysread $self->{socket}, my $response, 16;
	if( 16 != length $response ) {
		die sprintf 'Wrong size response 16 != %d, $response = %s', length $response, $response;
	}

	my $response_length = $self->unpack_32bit_int( substr $response, 4, 4 );
	my $left_to_go = $response_length;
	while( $left_to_go > 0 ) {
		my $read = sysread $self->{socket}, my( $buffer ), $left_to_go;
		if( $read > 0 ) {
			$response .= $buffer; $left_to_go -= $read;
		}
		else {
			last;
		}
	}
	return $response;
}

sub parse_sexp {
	my( $self, $response, $offset, $attr_aref ) = @ARG;
	my $i = $offset;
	my $sexp_type   = $self->unpack_8bit_int( substr $response, $i, 1 );
	my $sexp_length = $self->unpack_24bit_int( substr $response, $i + 1, 3 );
	$i += 4;
	$offset = my $end_of_sexp = $i + $sexp_length;
 warn sprintf 'data type %d, length %d, with payload from %d to %d', ( $sexp_type & 63 ), $sexp_length, $i, $end_of_sexp;

	# double array
	if( $sexp_type == Rsrv::XT_ARRAY_DOUBLE ) {
		my @doubles;
		while( $i < $end_of_sexp ) {
			push @doubles, $self->unpack_64bit_float( substr $response, $i, 8 );
			$i += 8;
		}
		return \@doubles;
	}

}

1;

