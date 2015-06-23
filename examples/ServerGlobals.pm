package demo::ServerGlobals;
use warnings;
use strict;

use base 'Exporter';
our @EXPORT = qw(
	$tt
	$router
	$api
	$app
);

use Lintel::Template::Factory;
our $tt = Lintel::Template::Factory->new(config => {
	INCLUDE_PATH => "$FindBin::Bin/templates",
	INTERPOLATE  => 1,
});

use Lintel::Router;
our $router = Lintel::Router->new();
our $api = $router->api;
our $app = $router->app;
