package examples::views::Home;
use warnings;
use strict;

use Lintel;

sub enlist {
	my ($class, $router) = @_;
	$router->add_route('/', target => \&home);
}

our $_links = [
	map {{ name => $_->[0], url => $_->[1] }}
	['Timers', '/timers'],
];

sub home {
	my $req = shift;
	return $tt->build('home.tmpl', title => 'Homepage', links => $_links)
		->execute;
}

1;
