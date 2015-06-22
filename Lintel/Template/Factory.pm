package Lintel::Template::Factory;
use Moose;
use Template;
use Lintel::Template::Builder;

our %default_config = (
	INCLUDE_PATH => './templates',
	INTERPOLATE  => 1,
);

has 'tt' => (
	is => 'rw',
	lazy => 1,
	default => sub {
		my $self = shift;
		Template->new(%{$self->config}) || die "$Template::ERROR\n";
	},
);

has 'config' => (
	is => 'rw',
	isa => 'HashRef',
	lazy => 1,
	default => sub {
		my %config = %default_config;
		return \%config;
	},
);

sub build {
	my ($self, $name, %args) = @_;
	return Lintel::Template::Builder->new(
		tt   => $self->tt,
		name => $name,
		args => \%args,
	);
}

1;
