package Lintel::Template::Builder;
use Moose;

extends 'Lintel::FutureBuilder';

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

sub execute {
	my $self = shift;
	return $self->collect->then(sub {
		my $output;
		my $success = $self->tt->process($self->name, $self->args, \$output);
		return $success ? Future->done($output)
		     :            Future->fail($self->tt->error . "\n")
		     ;
	})->get();
}

1;
