package Lintel::HTTP;
use warnings;
use strict;

use AnyEvent::HTTP qw( http_request );
use Lintel::Promise;
use JSON qw( decode_json );
use Smart::Comments;

use base 'Exporter';
our @EXPORT_OK = qw(
	do_http
	do_json

	unwrap_json
);

sub do_http {
	my ($method, $uri, @more) = @_;
	$uri = $uri->as_string
		if ref $uri;

	my $promise = Lintel::Promise->new();
	http_request($method, $uri, @more, sub {
		my ($body, $headers) = @_;
		return $promise->resolve(@_)
			if $headers->{Status} == 200;

		return $promise->reject( $headers->{Reason} );
	});
	return $promise;
}

sub unwrap_json {
	my $promise = shift;
	die "Not a promise: $promise"
		if !$promise->can('then');

	return $promise->then(sub {
		my ($body, $headers) = @_;
		return decode_json($body);
	});
}

sub do_json {
	return unwrap_json(do_http(@_));
}

1;
