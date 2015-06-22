#!/usr/bin/perl
use warnings;
use strict;

use FindBin;
use local::lib "$FindBin::Bin/../vendor";
use lib "$FindBin::Bin/../";

use HTTP::Server::PSGI;
use demo::ServerGlobals;

$router->register(qw(
	demo::WaitThree
	http://localhost:9092/
))->register_dir("$FindBin::Bin/views");

my $server = HTTP::Server::PSGI->new(
	host => "0.0.0.0",
	port => 9091,
	timeout => 120,
);

$server->run($app);
