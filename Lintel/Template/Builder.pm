package Lintel::Template::Builder;
use Moose;

extends 'Lintel::Promise::Builder';

has 'tt' => (
	is  => 'rw',
	isa => 'Template',
	required => 1,
);

has 'name' => (
	is  => 'rw',
	isa => 'Str',
	required => 1,
);

sub promise {
	my $self = shift;
	return $self->collect->then(sub {
		my $output;
		my $success = $self->tt->process($self->name, $self->args, \$output);
		return $success ? $output
		     :            die $self->tt->error . "\n"
		     ;
	});
}

sub execute {
	my $self = shift;
	return shift @{$self->promise->await};
}

1;
