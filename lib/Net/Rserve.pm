package Net::Rserve;
our $VERSION = '0.01';
use strict;
use warnings;
use 5.010;
use Carp();
use Data::Dumper;
use IO::Socket::INET;
use Time::HiRes qw(time);
use English qw(-no_match_vars);
use Rsrv();
use constant verbose => $ENV{RSERVE_VERBOSE};

__PACKAGE__->run if not caller;

sub run {
	my( $class ) = @ARG;

	my $self = $class->new;
	warn '$self = ', Dumper( $self ) if verbose;

	while( my $command = <STDIN> ) {
		chomp $command;
		my $result = $self->run_command( $command );
		warn '$result = ', Data::Dumper->new( [ $result ] )->Terse( 1 )->Dump;
	}

#	my $command = q{list( 1, 2, 3 )};
#	my $command = 'c( 0.1 + 0.2, 0.4, 0.5 )';
#	my $command = q{c("abc", "xyz", 0.1, 'qrs')};
#	my $command = q{list( 1, 'abc', 0.3 )};
#	my $command = q{pairlist( 'a', 1, 'b', 2 )};
#	my $command = q{pairlist( 'a' = 1, 'b' = 2 )};
#	my $command = 'c( 1, 2, 3 )';
#	my $command = 'c( "a", "b", "c" )';
#	my $command = 'list( TRUE, FALSE, TRUE )';
#	my $command = 'list( a = 1, b = 2 )';
#	my $command = "list( 0.1 + 0.2, 0.1 + 0.5 )";

	# From simple.php
#	my $command = "{x=rnorm(10); y=x+rnorm(10)/2; lm(y~x)}";
#	my $command = "list(str=R.version.string,foo=1:10,bar=1:5/2,logic=c(TRUE,FALSE,NA))";

}

sub new {
	my( $class ) = @ARG;

	my $self = bless {}, $class;

	$self->{socket} = IO::Socket::INET->new(
		PeerAddr => '127.0.0.1:6311',
		Type     => SOCK_STREAM,
		Blocking => 1,
	) or die 'Error connection - ', $OS_ERROR;

	my $read = sysread $self->{socket}, my $buffer, 32;
	die sprintf 'invalid header? %d != 32', $read if 32 != $read;
	warn '$buffer = ', $buffer if verbose;
	$self->{rserve_id_signature} = substr $buffer, 0, 4;
	$self->{rserve_version_protocol} = substr $buffer, 4, 4;
	$self->{rserve_communication_protocol} = substr $buffer, 8, 4;

	return $self;
}

sub run_command {
	my( $self, $command_string ) = @ARG; 
	die 'Need a $command_string' if not $command_string;

	my $packet  = $self->make_packet_string( Rsrv::CMD_eval, $command_string );
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

	my $i = 20;
	my $result = $self->parse_sexp( $response, \$i, );
	return $result;
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
	Carp::cluck '$num should be length 3' if 3 != length $num;
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
	Carp::cluck '$num should be length 4' if 4 != length $num;
	my $unpacked_32bit_int = unpack 'L', $num;
	return $unpacked_32bit_int;
}

sub unpack_64bit_float {
	my( $self, $num ) = @ARG;
	Carp::cluck '$num should be length 8' if 8 != length $num;
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
	my( $self, $response, $offset_sref ) = @ARG;
	my $i = ${ $offset_sref };
	my $sexp_type   = $self->unpack_8bit_int( substr $response, $i, 1 );
	my $sexp_length = $self->unpack_24bit_int( substr $response, $i + 1, 3 );
	$i += 4;
	${ $offset_sref } = my $end_of_sexp = $i + $sexp_length;
	warn sprintf 'data type %d, length %d, with payload from %d to %d', ( $sexp_type & 63 ), $sexp_length, $i, $end_of_sexp if verbose;

	if( ( $sexp_type & Rsrv::XT_LARGE ) == Rsrv::XT_LARGE ) {
		die 'sorry, long packets are not supported (yet).';
	}

	my $attr_href;
	if( $sexp_type > 127 ) {
		warn 'ATTR NAMES' if verbose;
		$sexp_type &= 127;
		my $attribute_length = $self->unpack_24bit_int( substr $response, $i + 1, 3 );
		my $tmpi = $i; # Don't want to persist change to $i here.
		$attr_href = $self->parse_sexp( $response, \$tmpi );
#		warn '$attr_href = ', Dumper( $attr_href );
		$i += $attribute_length + 4;
	} 

	if( $sexp_type == 0 ) {
		warn 'SEXP_TYPE 0' if verbose;
		return;
	}

	# generic vector
	if( $sexp_type == Rsrv::XT_VECTOR ) {
		warn 'XT_VECTOR' if verbose;
		my @vector;
		while( $i < $end_of_sexp ) {
			push @vector, $self->parse_sexp( $response, \$i );
		}
		# if the 'names' attribute is set, convert the plain array into a map
		if( my $names_aref = $attr_href->{names} ) {
			my %vector;
			for my $k ( 0 .. $#vector ) {
				$vector{ $names_aref->[ $k ] } = $vector[ $k ];
			}
			return \%vector;
		}
		return \@vector;
	}

	# symbol
	if( $sexp_type == Rsrv::XT_SYMNAME ) {
		warn 'XT_SYMNAME' if verbose;
		my $original_i = $i;
		while( $i < $end_of_sexp && ord( substr $response, $i, 1 ) != 0 ) {
			$i++;
		}
		return substr $response, $original_i, $i - $original_i;
	}

	# pairlist w/o tags
	if( $sexp_type == Rsrv::XT_LIST_NOTAG || $sexp_type == Rsrv::XT_LANG_NOTAG ) {
		warn 'XT_LIST_NOTAG || XT_LANG_NOTAG' if verbose;
		my @pairlist;
		while( $i < $end_of_sexp ) {
			push @pairlist, $self->parse_sexp( $response, \$i );
		}
		return \@pairlist;
	}

	# pairlist with tags
	if( $sexp_type == Rsrv::XT_LIST_TAG || $sexp_type == Rsrv::XT_LANG_TAG ) {
		warn 'XT_LIST_TAG || XT_LANG_TAG' if verbose; 
		my %pairlist;
		while( $i < $end_of_sexp ) {
			my $val = $self->parse_sexp( $response, \$i );
			my $tag = $self->parse_sexp( $response, \$i );
			$pairlist{ $tag } = $val;
		}
		return \%pairlist;
	}

	# integer array
	if( $sexp_type == Rsrv::XT_ARRAY_INT ) {
		warn 'XT_ARRAY_INT' if verbose;
		my @integers;
		while( $i < $end_of_sexp ) {
			push @integers, $self->unpack_32bit_int( substr $response, $i, 4 );
			$i += 4;
		}
		return @integers == 1 ? $integers[ 0 ] : \@integers;
	}
 
	# double array
	if( $sexp_type == Rsrv::XT_ARRAY_DOUBLE ) {
		warn 'XT_ARRAY_DOUBLE' if verbose;
		my @doubles;
		while( $i < $end_of_sexp ) {
			push @doubles, $self->unpack_64bit_float( substr $response, $i, 8 );
			$i += 8;
		}
		return @doubles == 1 ? $doubles[ 0 ] : \@doubles;
	}

	# string array
	if( $sexp_type == Rsrv::XT_ARRAY_STR ) {
		warn 'XT_ARRAY_STR' if verbose;
		my @strings;
		my $original_i = $i;
		while( $i < $end_of_sexp ) {
			if( ord( substr $response, $i, 1 ) == 0 ) {
				push @strings, substr $response, $original_i, $i - $original_i;
				$original_i = $i + 1;
			}
			$i++;
		}
		return @strings == 1 ? $strings[ 0 ] : \@strings;
	}

	# boolean vector
	if( $sexp_type == Rsrv::XT_ARRAY_BOOL ) {
		warn 'XT_ARRAY_BOOL' if verbose;
		my $n = $self->unpack_32bit_int( substr $response, $i, 4 );
		$i += 4;
		my $k = 0;
		my @booleans;
		while( $k < $n ) {
			my $v = $self->unpack_8bit_int( substr $response, $i++, 1 );
			$booleans[ $k++ ] = ( $v == 1 ) ? 1 : ( $v == 0 ) ? 0 : ();
		}
		return $n == 1 ? $booleans[ 0 ] : \@booleans;
	}

	# raw vector
	if( $sexp_type == Rsrv::XT_RAW ) {
		warn 'XT_RAW' if verbose;
		my $len = $self->unpack_32bit_int( $response, $i, 4 );
		$i += 4;
		return substr $response, $i, $len;
	}

	# unimplemented type in Rserve
	if( $sexp_type == Rsrv::XT_UNKNOWN ) {
		warn 'XT_UNKNOWN' if verbose;
		my $unimplemented_type = $self->unpack_32bit_int( $response, $i, 4 );
		warn "Note: result contains type $unimplemented_type unsupported by Rserve.";
		return;
	}

	warn "Warning: type $sexp_type is currently not implemented in the Perl client";
	return;
}

1;

=head1 NAME

Net::Rserve

=head1 SYNOPSIS

  use strict;
  use warnings;
  use Data::Dumper;
  use Net::Rserve();
  my $rserve = Net::Rserve->new;
  my $result = $rserve->run_command( "list(str=R.version.string,foo=1:10,bar=1:5/2,logic=c(TRUE,FALSE,NA))" );
  warn Dumper( $result );

=head1 DESCRIPTION

  An adaptation of C<simple.php> by Simon Urbanek.

=head1 CAVEATS

Apparently, if variables are set in one connection, they will still be available in other connections.
Once all connections are gone, the variables are apparently cleaned up and not available to 
subsequent connections.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself.

=head1 AUTHOR

Ben B.

=cut

