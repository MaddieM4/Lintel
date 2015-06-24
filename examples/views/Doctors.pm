package examples::views::Doctors;
use warnings;
use strict;

use Lintel;

sub enlist {
	my ($class, $router) = @_;
	$router->add_route('/doctors/', target => \&doctors);
}

sub doctors {
	return $tt->build('doctors.tmpl')
		->req('doctors', $api->get('/api/doctor/'))
		->execute;
}

1;
