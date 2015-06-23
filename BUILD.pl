use warnings;
use strict;
use Module::Build;

my $builder = Module::Build->new(
	module_name    => 'Lintel',
	license        => 'perl',
	dist_abstract  => 'Microframework based on Plack',
	dist_author    => 'Philip Horger <philip@inspire.com>',
	release_status => 'unstable',
	build_requires => {
		'Test::More' => '0.10',
	},
);

$builder->create_build_script();
