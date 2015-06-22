package Lintel::App;
use Moose;
use Smart::Comments;
use JSON qw( encode_json );
extends 'Plack::App::Path::Router';

=head1 NAME

Lintel::App - A slight extension of Plack::App::Path::Router

=head1 SYNOPSIS

    # In some module
    sub my_handler {
        return Future->done('blah');
    }

    # In your server config
    my $app = Lintel::Router->new()->register('MyModule')->app;

=head1 DESCRIPTION

Our base class gets us support for a few cool things, building upon Path::Router.
For example, we can return a string, and that will be interpreted as a 200 text/plain.

We're taking it a tiny step further, by natively supporting Futures, including JSON
object payloads. This makes it trivial to return results based on deferred queries.
For example, this is used by Lintel::Template::Builder, which returns a Future that
will contain either HTML or failure.

=cut

has '+handle_response' => (
    default => sub {
        sub {
            my ($res) = @_;

	    # Our custom hook
            if ( blessed $res && $res->isa('Future') ) {
                return _finalize_future($res);
            }

	    # Stock PAPR
            if ( blessed $res && $res->can('finalize') ) {
                return $res->finalize;
            }
            elsif ( not ref $res ) {
                return [ 200, [ 'Content-Type' => 'text/html' ], [ $res ] ];
            }
            else {
                return $res;
            }
        };
    },
);

sub _finalize_future {
	my $future = shift;
	my $response = [500, ['Content-type' => 'text/plain'], ["Unknown failure"]];
	### Before wait
	$future->await;
	### After wait
	$response = _finalize_object(200, $future->get)
		if $future->is_done;
	$response = _finalize_object(500, $future->failure)
		if $future->is_failed;
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
