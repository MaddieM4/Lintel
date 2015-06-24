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
	['Timers (with more oomph)', '/timers?concurrency=20'],
	['Doctors (CRUD+AJAX)', '/doctors'],
];

sub home {
	my $req = shift;
	return $tt->build('home.tmpl', title => 'Homepage', links => $_links)
		->execute;
}

1;
