package Lintel::Template::Builder;
use Moose;
use Lintel::ResponseFuture;

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
	my $future = $self->collect->then(sub {
		my $output;
		my $success = $self->tt->process($self->name, $self->args, \$output);
		return $success ? Future->done($output)
		     :            Future->fail($self->tt->error . "\n")
		     ;
	});
	return Lintel::ResponseFuture->wrap($future);
}

1;
