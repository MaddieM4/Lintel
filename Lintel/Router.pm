package Lintel::Router;
use Moose;
use Plack::App::Path::Router;

extends 'Path::Router';

sub register {
	my ($self, @handlers) = @_;
	map { $self->_register($_) } @handlers;
	return $self;
}

sub _register {
	my ($self, $name) = @_;
	# TODO: detect http(s) urls
	return $self->_register_module($_);
}

sub _register_module {
	my ($self, $name) = @_;
	eval "use $name"; die $@ if $@;
	$name->enlist($self);
}

sub app {
	my $self = shift;
	return Plack::App::Path::Router->new(router => $self);
}

1;
