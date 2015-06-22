package Lintel::FutureBuilder;
use Moose;
use Future;

has 'args' => (
	is  => 'rw',
	isa => 'HashRef',
	required => 1,
);

has 'auto_wrap' => (
	is  => 'rw',
	isa => 'Bool',
	default => 1,
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

sub wrap {
	my ($self, $future) = @_;
	die "Not a Future"
		if !$self->auto_wrap && !$future->isa('Future');
	if (ref $future eq 'CODE') {
		my $result = eval $future;
		return $@ ? Future->fail($@) : Future->done($result);
	}
	return Future->wrap($future);
}

sub _prep_future {
	my ($self, $param, $future) = @_;
	$future = $self->wrap($future);

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
