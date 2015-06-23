package demo::WaitThree;
use warnings;
use strict;

sub enlist {
	my ($class, $router) = @_;
	$router->add_route('/api/wait/3s', target => \&wait);
}

sub wait {
	my $req = shift;
	sleep 3;
	'Waited three seconds';
}

1;
