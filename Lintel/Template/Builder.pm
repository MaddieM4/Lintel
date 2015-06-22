package Lintel::Template::Builder;
use Moose;
use Plack::Response;

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
		$self->tt->process($self->name, $self->args, \$output)
			or die $self->tt->error . "\n";

		my $res = Plack::Response->new(200);
		$res->content_type('text/html');
		$res->body($output);
		return $res;
	});
}

sub execute {
	my $self = shift;
	return shift @{$self->promise->await};
}

sub raw {
	my $self = shift;
	return $self->promise->finalize->[2];
}

1;
