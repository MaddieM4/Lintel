#!/usr/bin/perl
use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib/";
use lib "$FindBin::Bin/../";

use Lintel;

$tt->extend(
	WRAPPER => 'site_wrapper.tmpl',
);

$router->register(qw(
	examples::WaitThree
	http://localhost:9092/
))->register_dir("$FindBin::Bin/views");

$router->standalone(port => 9091);
