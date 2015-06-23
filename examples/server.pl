#!/usr/bin/perl
use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib/";

use Lintel;

$router->register(qw(
	examples::WaitThree
	http://localhost:9092/
))->register_dir("$FindBin::Bin/views");

$router->standalone(port => 9091);
