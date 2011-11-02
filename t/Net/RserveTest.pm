package Net::RserveTest;
use strict;
use warnings;
use English qw(-no_match_vars);
use constant TEST_PACKAGE => substr __PACKAGE__, 0, -4;
use parent 'Test::Class';
use IPC::Open3 qw(open3);
use Symbol 'gensym';
use Test::More;
use Test::Exception;
use constant RSERVE_SKIP_NETWORK_TESTS => $ENV{RSERVE_SKIP_NETWORK_TESTS};

__PACKAGE__->new->runtests if not caller;

sub start : Tests(startup => 1) {
	my( $self ) = @ARG;
	require_ok( $self->TEST_PACKAGE );
}

sub test_run_command_1 : Tests {
	my( $self ) = @ARG;
	return 'Skipping Rserve network tests' if $self->RSERVE_SKIP_NETWORK_TESTS;

	my $rserve;
	lives_ok { $rserve = $self->TEST_PACKAGE->new; };
	isa_ok( $rserve, $self->TEST_PACKAGE );

	do {
		my $result = $rserve->run_command( 'list( 1, 2, 3 )' );
		is_deeply( $result,  [ 1, 2, 3 ] );
	};

	do {
		my $result = $rserve->run_command( 'c( 0.1 + 0.2, 0.4, 0.5 )' );
		is_deeply( $result,  [ '0.3', '0.4', '0.5' ] );
	};

	do {
		my $result = $rserve->run_command( q{c("abc", "xyz", 0.1, 'qrs')} );
		is_deeply( $result,  [ 'abc', 'xyz', '0.1', 'qrs' ] );
	};

	do {
		my $result = $rserve->run_command( q{list( 1, 'abc', 0.3 )} );
		is_deeply( $result,  [ '1', 'abc', '0.3' ] );
	};

	do {
		my $result = $rserve->run_command( q{pairlist( 'a', 1, 'b', 2 )} );
		is_deeply( $result,  [ 'a', '1', 'b', '2' ] );
	};

	do {
		my $result = $rserve->run_command( q{pairlist( 'a' = 1, 'b' = 2 )} );
		is_deeply( $result,   { 'a' => '1', 'b' => '2' } );
	};

	do {
		my $result = $rserve->run_command( q{c( 1, 2, 3 )} );
		is_deeply( $result, [ 1, 2, 3 ] );
	};

	do {
		my $result = $rserve->run_command( q{c( 1, 2, 3 )} );
		is_deeply( $result, [ 1, 2, 3 ] );
	};

	do {
		my $result = $rserve->run_command( q{c( "a", "b", "c" )} );
		is_deeply( $result, [ 'a', 'b', 'c' ] );
	};

	do {
		my $result = $rserve->run_command( q{list( TRUE, FALSE, TRUE, NA )} );
		is_deeply( $result, [ 1, 0, 1, undef ] );
	};

	do {
		my $result = $rserve->run_command( q{list( a = 1, b = 2 )} );
		is_deeply( $result,  { 'a' => '1', 'b' => '2' } );
	};

	do {
		my $result = $rserve->run_command( q{list( 0.1 + 0.2, 0.1 + 0.5 )} );
		is_deeply( $result, [ '0.3', '0.6' ] );
	};

	do {
		my $result = $rserve->run_command( q'list(str=R.version.string,foo=1:10,bar=1:5/2,logic=c(TRUE,FALSE,NA))' );
		is_deeply( $result,  {
				'bar' => [
					'0.5',
					'1',
					'1.5',
					'2',
					'2.5'
				],
				'str' => 'R version 2.13.2 (2011-09-30)',
				'foo' => [
					1,
					2,
					3,
					4,
					5,
					6,
					7,
					8,
					9,
					10
				],
				'logic' => [
					1,
					0,
					undef
				]
			}
		);
	};

	do {
		is( $rserve->run_command( q{x <- 1} ), 1 );
		is( $rserve->run_command( q{y <- 0.1} ), 0.1 );
		is( $rserve->run_command( q{x + y} ), 1.1 );
	};

	do {
		# x and y ARE available on this connection.
		my $rserve1 = $self->TEST_PACKAGE->new;
		lives_ok { is( $rserve->run_command( q{x + y} ), 1.1 ); };
	};

	undef $rserve;

	do {
		# x and y are NOT available on this connection.
		my $rserve1 = $self->TEST_PACKAGE->new;
		dies_ok { warn 'x + y ', $rserve->run_command( q{x + y} ); };
	};
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

