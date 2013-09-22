package CodeJuicer::DB;
use Modern::Perl;
use MongoDB;

=head1 NAME

CodeJuicer::DB - a thin layer on top of MongoDB

=head1 DESCRIPTION

Create a connection to the MongoDB server and connect to the 'codejuicer'
database.

=head1 GLOBAL VARIABLES

=head2 $client

L<MongoDB::Connection>, the connection to the MongoDB server itself.

=head2 $db

L<MongoDB::Database> instance for database name 'codejuicer'.

=cut

our $client = MongoDB::Connection->new;
our $db = $client->get_database('codejuicer');

=head1 METHODS

=head2 c($collection_name)

Returns a L<MongoDB::Collection> related to the given collection name.

=cut

sub c {
  my (undef, $collection_name) = @_;
  $db->get_collection($collection_name);
}

1;

=head1 AUTHOR

Joenio Costa <joenio@colivre.coop.br>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Joenio Costa

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.
