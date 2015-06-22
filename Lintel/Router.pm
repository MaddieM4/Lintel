package Lintel::Router;
use Moose;
use Plack::App::Path::Router;
use Lintel::HTTP qw( do_json );
use Data::Dumper;
use Smart::Comments;

extends 'Path::Router';

sub register {
	my ($self, @handlers) = @_;
	map { $self->_register($_) } @handlers;
	return $self;
}

sub _register {
	my ($self, $name) = @_;
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
	my $details = do_json(uri => $uri)->get;
	
	for my $spec (@$details) {
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
				return do_json(uri => $outbound);
			});
		}
	}
}

sub app {
	my $self = shift;
	return Plack::App::Path::Router->new(router => $self);
}

1;
