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
	default => sub { rebuild_tt(shift, 1) },
);

has 'config' => (
	is => 'rw',
	isa => 'HashRef',
	lazy => 1,
	default => sub {
		my %config = %default_config;
		return \%config;
	},
	trigger => \&rebuild_tt,
);

sub build {
	my ($self, $name, %args) = @_;
	return Lintel::Template::Builder->new(
		tt   => $self->tt,
		name => $name,
		args => \%args,
	);
}

sub rebuild_tt {
	my ($self, $just_return) = @_;
	my $tt = Template->new(%{$self->config}) || die "$Template::ERROR\n";
	$self->tt($tt)
		if !$just_return;
	return $tt;
}

sub extend {
	my $self = shift;
	my $original_config = $self->config;
	$self->config({ %$original_config, @_ });
}

1;
