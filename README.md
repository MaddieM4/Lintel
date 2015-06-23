[![Build Status](https://travis-ci.org/campadrenalin/Lintel.svg?branch=master)](https://travis-ci.org/campadrenalin/Lintel)
# NAME

Lintel - A microframework for Perl + microservices

# SYNOPSIS

    use Lintel;
    $tt->config({
        INCLUDE_PATH => '...',
    });
    $router
        ->register_dir('./API/')
        ->register_dir('./Views/')
        ->register(qw(
            http://localhost:4040/
            http://other_server.com/
    ));
    $router->app; # Feed this to a PSGI server

    # ./Views/Widgets.pm
    package MyApp::Views::Widgets;
    use warnings;
    use strict;

    use Lintel;

    sub enlist {
        my ($class, $router) = @_;
        $router->add_route('/widgets', \&widgets);
    }

    sub widgets {
        my $req = shift; # Plack::Request
        # Bake API results into template params
        # All external API requests will occur in parallel
        return $tt->build('widgets.html')
            ->req('quick_widget', $api->get('/api/widget/quick'))
            ->req('slow_widget', $api->get('/api/widget/slow', some_param => 12))
            ->execute;
    }

# DESCRIPTION

Lintel is a small framework - barely a frame, hence the name. It's designed to be
a drop-in component in larger projects, for example mod\_perl sites, that immediately
makes it easier to define strong lines and loose coupling between components, put
more of your site into public or private API form, and push more of the heavy lifting
into asynchronous microservices, which can chug in parallel.

The highlights of this project are the API router, which lets you treat your internal
and external logic agnostically, and the Template builder, which provids a fluent
construction syntax without straying into any really esoteric DSL space - it's still
Perl, and it's not hiding how it's working.

# AUTHOR

Philip Horger <campadrenalin@gmail.com>

# LICENSE

        This library is free software; you may redistribute it and/or
            modify it under the same terms as Perl itself.
