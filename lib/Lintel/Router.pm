package Lintel::Router;
use Moose;

use IPC::Run qw( run );
use Lintel::API;
use Lintel::HTTP qw( do_json );
use Plack::App::Path::Router;

use Data::Dumper;

extends 'Path::Router';

sub register {
	my ($self, @handlers) = @_;
	map { $self->_register($_) } @handlers;
	return $self;
}

sub register_dir {
	my ($self, $dirname) = @_;
	my $output;
	run(
		['grep', '-Ro', '^package \([^;]*\)', $dirname],
		'|', ['cut', '-d ', '-f2'],
		'>', \$output
	) || die "Find failure: $!";

	$self->register(split "\n", $output);
}

sub _register {
	my ($self, $name) = @_;
	### Registering: $name
	return $self->_register_service($name)
		if $name =~ m#^https?://#;
	return $self->_register_module($name);
}

sub _register_module {
	my ($self, $name) = @_;
	eval "use $name"; die $@ if $@;
	$name->enlist($self);
}

sub _register_service {
	my ($self, $uri) = @_;
	$uri = URI->new($uri);
	$uri->path('/api/available');
	my $details = shift @{do_json('GET', $uri)->await};
	
	map { $self->_install_service_spec($uri, $_) } @$details;
}

sub _install_service_spec {
	my ($self, $uri, $spec) = @_;

	# Labels are from microservice perspective - reverse them
	my ($mine, $yours, $children) = @{$spec}{qw(base_yours base_mine children)};
	die "Insufficient service data: ", Dumper($spec)
		if !($mine && $yours);
	push(@$children, '')
		if !@$children;

	for my $child (@$children) {
		my ($internal, $external) = ($mine . $child, $yours . $child);
		my $outbound = $uri->clone;
		$outbound->path($external);
		$self->add_route($mine . $child, target => sub {
			my $request = shift;
			return do_json('GET', $outbound);
		});
	}
}

sub app {
	my $self = shift;
	return Plack::App::Path::Router->new(router => $self);
}

sub api {
	my $self = shift;
	return Lintel::API->new(router => $self);
}

1;
