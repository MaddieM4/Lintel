package Lintel::Async;
use warnings;
use strict;

=head1 NAME

Lintel::Async - Global Async utilities

=head1 SYNOPSIS

    use Lintel::Async qw( new_future );
    my $future = new_future->done(data);

    use Lintel::Async qw( do_request );
    my $http_req_future = do_request("http://twitter.com/api/...");

=head1 DESCRIPTION

A singleton module that makes it easy for the whole process
to share an async reactor and generate futures for it.

=cut

use IO::Async::Loop;
use Net::Async::HTTP;
use JSON qw( decode_json );
use URI;
use Future;
use base 'Exporter';

our ($loop, $http);
our @EXPORT_OK = qw(
	new_future
	do_request
	do_json_request
);

sub _init {
	return if $loop;

	# Shared HTTP client for connection pooling
	$loop = IO::Async::Loop->new();
	$http = Net::Async::HTTP->new();
	$loop->add($http);
}

sub new_future {
	_init();
	return $loop->new_future;
}

sub do_request {
	_init();
	return $http->do_request(@_);
}
sub do_json_request {
	return do_request(@_)->then(sub {
		my $response = shift;
		my $raw = $response->decoded_content(raise_error => 1, ref => 1);
		chomp $$raw;
		return Future->done(decode_json($$raw));
	});
}

1;
