package Hash::Util::FieldHash::Compat;
BEGIN {
  $Hash::Util::FieldHash::Compat::AUTHORITY = 'cpan:NUFFIN';
}
# git description: v0.07-10-g6248c0b
$Hash::Util::FieldHash::Compat::VERSION = '0.08';
# ABSTRACT: Use Hash::Util::FieldHash or ties, depending on availability
# KEYWORDS: fields hashes fieldhash backwards compatibility backcompat tie

use strict;
use warnings;

use constant REAL_FIELDHASH => do { local $@; local $SIG{__DIE__}; eval { require Hash::Util::FieldHash } };

BEGIN {
    if ( REAL_FIELDHASH ) {
        require Hash::Util::FieldHash;
        Hash::Util::FieldHash->import(":all");
    } else {
        require Hash::Util::FieldHash::Compat::Heavy;
    }
}

sub import {
    if ( REAL_FIELDHASH ) {
        my $class = "Hash::Util::FieldHash";

        shift @_;
        unshift @_, $class;

        goto $class->can("import");
    } else {
        my $class = shift;
        $class->export_to_level(1, $class, @_);
    }
}

__PACKAGE__

__END__

=pod

=encoding UTF-8

=head1 NAME

Hash::Util::FieldHash::Compat - Use Hash::Util::FieldHash or ties, depending on availability

=head1 VERSION

version 0.08

=head1 SYNOPSIS

    use Hash::Util::FieldHash::Compat;

    # pretend you are using L<Hash::Util::FieldHash>
    # under older perls it'll be Tie::RefHash::Weak instead (slower, but same behavior)

=head1 DESCRIPTION

Under older perls this module provides a drop-in compatible API to
L<Hash::Util::FieldHash> using L<perltie>. When L<Hash::Util::FieldHash> is
available it will use that instead.

This way code requiring field hashes can benefit from fast, robust field hashes
on Perl 5.10 and newer, but still run on older perls that don't ship with that
module.

See L<Hash::Util::FieldHash> for all the details of the API.

=head1 SEE ALSO

L<Hash::Util::FieldHash>, L<Tie::RefHash>, L<Tie::RefHash::Weak>.

=head1 AUTHOR

יובל קוג'מן (Yuval Kogman) <nothingmuch@woobling.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2008 by יובל קוג'מן (Yuval Kogman).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 CONTRIBUTORS

=over 4

=item *

Karen Etheridge <ether@cpan.org>

=item *

Yuval Kogman <nothingmuch@woobling.org>

=back

=cut
