package Lintel::Promise::Builder;
use Moose;
use Lintel::Promise;
use Promises;

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

has '_promises' => (
	is  => 'ro',
	isa => 'ArrayRef[Lintel::Promise]',
	default => sub { [] },
);

sub wrap {
	my ($self, $promise) = @_;
	die "Not a Promise"
		if !$self->auto_wrap && !$promise->can('then');
	return Lintel::Promise->wrap($promise);
}

sub _prep_promise {
	my ($self, $param, $promise, $fallback) = @_;
	$promise = $self->wrap($promise);
	$promise = $promise->catch($fallback)
		if $fallback;

	my $finisher = (ref $param eq 'CODE') ? sub { return $param->($self, @_) }
	           :                            sub { $self->args->{$param} = shift }
		   ;
	return $promise->then($finisher);
}

sub _append {
	my $self = shift;
	push(@{$self->_promises}, $self->_prep_promise(@_));
	return $self;
}

sub req {
	my ($self, $param, $promise) = @_;
	return $self->_append($param, $promise);
}
sub opt {
	my ($self, $param, $promise, $fallback) = @_;
	return $self->_append($param, $promise, $fallback || \&box_error );
}

sub _box_error {
	my ($statement) = shift;
	return { error => $statement, more => [@_] };
}

sub collect {
	my $self = shift;
	return $self->wrap(Promises::collect( @{$self->_promises} ));
}

1;
