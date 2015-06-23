#!/usr/bin/perl
use warnings;
use strict;

use FindBin;
#use local::lib "$FindBin::Bin/../vendor";
use lib "$FindBin::Bin/../lib/";

use Lintel::Promise;
use Data::Dumper;
use Scalar::Util qw( blessed );

use Lintel::Template::Factory;
our $tmpl = Lintel::Template::Factory->new(config => {
	INCLUDE_PATH => "$FindBin::Bin/templates",
	INTERPOLATE  => 1,
});

my $result = $tmpl->build("hello.tmpl", title => 'foo')
	->req("content", Lintel::Promise->wrap("example"));

print Data::Dumper->Dump([
	blessed($result),
	blessed($result->promise),
	blessed($result->execute),
	$result->promise->finalize,
	$result->raw,
], [qw(
	blessed($result)
	blessed($result->promise)
	blessed($result->execute)
	$result->promise->finalize
	$result->raw
)]);
