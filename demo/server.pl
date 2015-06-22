#!/usr/bin/perl
use warnings;
use strict;

use FindBin;
use local::lib "$FindBin::Bin/../vendor";
use lib "$FindBin::Bin/../";

use Lintel::Router;
use HTTP::Server::PSGI;

my $app = Lintel::Router->new()->register(qw(
	demo::WaitThree
	http://localhost:9092/
))->app;

my $server = HTTP::Server::PSGI->new(
	host => "0.0.0.0",
	port => 9091,
	timeout => 120,
);

$server->run($app);
