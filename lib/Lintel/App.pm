package Lintel::App;
use Moose;
use JSON qw( encode_json );

extends 'Plack::App::Path::Router';

has '+handle_response' => (
    default => sub {
        sub {
            my ($res) = @_;
	    # Our customization
	    return [ 200, [ 'Content-Type' => 'application/javascript' ], [ encode_json($res) ]]
	    	if ref $res eq 'HASH';

	    # Original
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

1;
