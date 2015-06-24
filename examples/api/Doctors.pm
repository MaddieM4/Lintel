package examples::api::Doctors;
use warnings;
use strict;
#use Smart::Comments;

sub enlist {
	my ($class, $router) = @_;
	$router->add_route('/api/doctor/',     target => \&no_id);
	$router->add_route('/api/doctor/:id/', target => \&with_id);
}

our $not_supported = [405, ['Content-type' => 'text/plain'], ['Method not supported']];
our $doctors = [ {
	id    => 0,
	name  => 'Freddy',
	creds => 'M.D.',
	tools => ['stethoscope', 'penicillin'],
	phrase => 'No country for old men!',
} ];

sub no_id {
	my $req = shift;
	my $method = $req->method;
	return $method eq 'GET'  ? list_doctors($req)
	     : $method eq 'POST' ? new_doctor($req)
	     :                     $not_supported
	     ;
}

sub with_id {
	my $req = shift;
	my $method = $req->method;
	return $method eq 'PUT'    ? update_doctor($req)
	     : $method eq 'DELETE' ? delete_doctor($req)
	     :                       $not_supported
	     ;
}

sub list_doctors {
	my $req = shift;
	return {
		doctors => [grep { $_ } @$doctors],
	}
}

sub _trim {
	my $str = shift;
	$str =~ s/^\s+|\s+$//g;
	return $str;
}

sub new_doctor {
	my $req = shift;
	my %params = map {
		my $key = $_;
		my $value = $req->parameters->{$key};
		die "No value for $key" if !$value;
		($key => $value);
	} qw( name   creds   tools   phrase);
	$params{tools} = [
		map { _trim($_) }
		split ",", $params{tools}
	];
	$params{id} = @$doctors;
	push(@$doctors, \%params);
	return \%params;
}

sub update_doctor {
}

sub delete_doctor {
}
