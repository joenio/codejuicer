package CodeJuicer::DB;
use Modern::Perl;
use MongoDB;

our $client = MongoDB::Connection->new;
our $db = $client->get_database('codejuicer');

sub c {
  my (undef, $collection_name) = @_;
  $db->get_collection($collection_name);
}

1;
