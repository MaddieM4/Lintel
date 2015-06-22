package Lintel::Template::Builder;
use Moose;
use Future;

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

has 'args' => (
	is  => 'rw',
	isa => 'HashRef',
	required => 1,
);

has '_required' => (
	is  => 'ro',
	isa => 'ArrayRef[Future]',
	default => sub { [] },
);
has '_optional' => (
	is  => 'ro',
	isa => 'ArrayRef[Future]',
	default => sub { [] },
);

sub _prep_future {
	my ($self, $param, $future) = @_;
	die "Not a Future" if !$future->isa('Future');

	if (ref $param eq 'CODE') {
		$future->on_done(sub {
			return $param->($self, @_)
		});
	} else {
		$future->on_done(sub {
			$self->args->{$param} = shift;
		});
	}
	return $future;
}

sub req {
	my ($self, $param, $future) = @_;
	push(@{$self->_required}, $self->_prep_future($param, $future));
	return $self;
}

sub opt {
	my ($self, $param, $future) = @_;
	push(@{$self->_optional}, $self->_prep_future($param, $future));
	return $self;
}

sub collect {
	my $self = shift;
	return Future->needs_all(
		Future->needs_all(@{$self->_required}),
		Future->wait_all(@{$self->_optional}),
	);
}

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
