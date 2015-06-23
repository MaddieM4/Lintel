requires 'perl', '5.008001';

requires 'Plack',          '1.00';
requires 'Template',       '2.26';
requires 'AnyEvent::HTTP', '2.22';
requires 'IPC::Run',       '0.94';
requires 'JSON',           '2.90';
requires 'Moose',          '2.00';
requires 'Promises',       '0.94';
requires 'Scalar::Util',   '1.42';
requires 'Plack::App::Path::Router', '0.08';

on 'test' => sub {
    requires 'Test::More', '0.98';
};
