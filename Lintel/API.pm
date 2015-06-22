package Lintel::API;
use Moose;
use Plack::Request;

has 'router' => (
	is  => 'ro',
	isa => 'Lintel::Router',
	required => 1,
);

sub get_target {
	my ($self, $uri) = @_;
	my $match = $self->router->match($uri);
	die "No match for $uri"
		if !$match;
	return $match->target, $match->mapping;
}

sub do {
	my ($self, $method, $uri, $params) = @_;
	my ($target, $mapping) = $self->get_target($uri);
	my $req = Plack::Request->new({
		'plack.request.merged' => [%$mapping, %$params],
		PATH_INFO              => $uri,
		REQUEST_METHOD         => $method,
	});
	return $target->($req);
}

sub get {
	my ($self, $uri, %params) = @_;
	return $self->do('GET', $uri, \%params);
}

1;
