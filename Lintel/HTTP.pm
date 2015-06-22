package Lintel::HTTP;
use warnings;
use strict;

use AnyEvent::HTTP qw( http_request );
use Lintel::Promise;
use JSON qw( decode_json );

sub do_http {
	my $promise = Lintel::Promise->new();
	http_request(@_, sub {
		my ($body, $headers) = @_;
		return $deferred->resolve(@_)
			if $headers->{Status} == 200;

		return $deferred->reject( $headers->{Reason} );
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
