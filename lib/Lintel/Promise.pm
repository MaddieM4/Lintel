package Lintel::Promise;
use Moose;
use AnyEvent::HTTP;
use JSON qw( encode_json );
use Promises backend => ['AnyEvent'];

has 'promise' => (
	is   => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		return $self->deferred->promise;
	},
);

has 'deferred' => (
	is  => 'ro',
	lazy => 1,
	default => sub {
		Promises::deferred();
	},
);

has 'action' => (
	is => 'rw',
	trigger => \&execute,
);

sub execute {
	my $self = shift;
	my $result = eval { $self->action->($self) };
	return $@              ? $self->reject($@)
	     : defined $result ? $self->resolve($result)
	     :                   $self
	     ;
}

sub resolve {
	my $self = shift;
	$self->deferred->resolve(@_);
	return $self;
}

sub reject {
	my $self = shift;
	$self->deferred->reject(@_);
	return $self;
}

sub wrap {
	my ($class, $object) = @_;
	if (blessed $object && $object->can('then')) {
		return $object->isa($class) ? $object
		     :                        $class->new(promise => $object)
		     ;
	}
	return $class->new(action => $object)
		if ref $object eq 'CODE';
	return $class->new()->resolve($object);
}

sub then {
	my $self = shift;
	my $then = $self->promise->then(@_);
	return $self->wrap($then);
}

sub catch {
	my $self = shift;
	return $self->wrap($self->promise->catch(@_));
}

sub await {
	my ($self, $cv) = @_;
	$cv ||= AnyEvent->condvar;
	$self->then(sub { $cv->send([@_]) }, sub { $cv->croak(@_) });
	return $cv->recv;
}

## Support returning these from module handlers
sub finalize {
	my $self = shift;
	my $response = [500, ['Content-type' => 'text/plain'], ["Unknown failure"]];
	$self->then(
		sub { $response = _finalize_object(200, @_) },
		sub { $response = _finalize_object(500, @_) },
	)->await;
	return $response;
}

sub _can_finalize {
	my $object = shift;
	return blessed $object && $object->can('finalize');
}

sub _finalize_object {
	my ($code, $object) = @_;
	# Plack::Response, mostly
	return $object->finalize() if _can_finalize($object);

	my $type = 'text/plain';
	if (ref $object ne 'SCALAR' && ref $object ne '') {
		$type = 'application/json';
		$object = encode_json($object);
	}
       	return [$code, ['Content-type' => $type], [$object]];
}

1;
