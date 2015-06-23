package examples::views::Home;
use warnings;
use strict;

use Lintel;

sub enlist {
	my ($class, $router) = @_;
	$router->add_route('/', target => \&home);
}

sub home {
	my $req = shift;

	# Demo - allow user to adjust concurrency
	local $AnyEvent::HTTP::MAX_PER_HOST = $req->parameters->{concurrency}
		if $req->parameters->{concurrency};

	my $callback = sub {
		my ($builder, $result) = @_;
		push(@{$builder->args->{timers}}, $result);
	};
	my $builder = $tt->build('home.tmpl', title => 'Homepage', timers => []);
	map { $builder->req($callback, $api->get('/api/wait/1s')) } (0..19);
	return $builder->execute;
}

1;
