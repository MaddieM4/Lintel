requires 'perl', '5.008001';

requires 'Plack', '1.0';
requires 'Template', '2.26';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

