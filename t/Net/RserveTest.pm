package Net::RserveTest;
use strict;
use warnings;
use English qw(-no_match_vars);
use constant TEST_PACKAGE => substr __PACKAGE__, 0, -4;
use parent 'Test::Class';
use IPC::Open3 qw(open3);
use Symbol 'gensym';
use Test::More;

__PACKAGE__->new->runtests if not caller;

sub start : Tests(startup => 1) {
	my( $self ) = @ARG;
	require_ok( $self->TEST_PACKAGE );
}

sub test_int8 : Tests {
	my( $self ) = @ARG;
	return 'skip';
	my $CHILD_ERR = gensym;
	my $pid = open3( my $CHILD_IN, my $CHILD_OUT, $CHILD_ERR, 'php php/int8.php' )
		or die 'Error opening php/int8.php for reading - ', $OS_ERROR;

	for my $i ( 1 .. 255 ) {
		my $c = pack 'C', $i;
		my $perl_unpacked_8bit_int = $self->TEST_PACKAGE->unpack_8bit_int( $c );
		syswrite $CHILD_IN, $c . "\n";
		sysread  $CHILD_OUT, my $php_unpacked_8bit_int, 3;
		# Found bug in the PHP code?
		if( $perl_unpacked_8bit_int ne $php_unpacked_8bit_int ) { # $i < 9 and $i > 12 and 
			fail( sprintf 'test_int8 %d failed: perl: %s, php: %s', $i, $perl_unpacked_8bit_int, $php_unpacked_8bit_int )
		}
	}
}

sub test_int24 : Tests {
	my( $self ) = @ARG;
	return 'skip';
	my $CHILD_ERR = gensym;
	my $pid = open3( my $CHILD_IN, my $CHILD_OUT, $CHILD_ERR, 'php php/int24.php' )
		or die 'Error opening php/int24.php for reading - ', $OS_ERROR;

	for my $i ( 1 .. 500 ) {
		my $int = substr pack( 'L', $i ), 0, 3;
		my $perl_unpacked_24bit_int = $self->TEST_PACKAGE->unpack_24bit_int( $int );
		syswrite $CHILD_IN, $int . "\n";
		sysread  $CHILD_OUT, my $php_unpacked_24bit_int, 3;
		if( $perl_unpacked_24bit_int ne $php_unpacked_24bit_int ) {
			fail( sprintf 'test_int24 %d failed: perl: %s, php: %s', $i, $perl_unpacked_24bit_int, $php_unpacked_24bit_int )
		}
	}
}

sub test_mkint24 : Tests {
	my( $self ) = @ARG;
	return 'skip';
	my $pid = open3( my $CHILD_IN, my $CHILD_OUT, my $CHILD_ERR, 'php php/mkint24.php' )
		or die 'Error opening php/mkint24.php for reading - ', $OS_ERROR;

	for my $i ( 1 .. 50000 ) {
		my $perl_packed_24bit_int = $self->TEST_PACKAGE->pack_24bit_int( $i );
		syswrite $CHILD_IN, $i . "\n";
		sysread  $CHILD_OUT, my $php_packed_24bit_int, 3;
		if( $perl_packed_24bit_int ne $php_packed_24bit_int ) {
			fail( sprintf 'test_mkint24 %d failed: perl: %s, php: %s', $i, $perl_packed_24bit_int, $php_packed_24bit_int )
		}
	}
}

sub test_mkint32 : Tests {
	my( $self ) = @ARG;
	return 'skip';
	my $pid = open3( my $CHILD_IN, my $CHILD_OUT, my $CHILD_ERR, 'php php/mkint32.php' )
		or die 'Error opening php/mkint32.php for reading - ', $OS_ERROR;

	# That should be enough.
	for my $i ( 1 .. 50000 ) {
		my $perl_packed_32bit_int = $self->TEST_PACKAGE->pack_32bit_int( $i );
		syswrite $CHILD_IN, $i . "\n";
		sysread  $CHILD_OUT, my $php_packed_32bit_int, 4;
		if( $perl_packed_32bit_int ne $php_packed_32bit_int ) {
			fail( sprintf 'test_mkint32 %d failed: perl: %s, php: %s', $i, $perl_packed_32bit_int, $php_packed_32bit_int )
		}
	}
}

#sub xxx_tests_done : Tests {
#	done_testing();
#}

1;

