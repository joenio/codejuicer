package CodeJuicer::Worker::Functions::cluster;
use Modern::Perl;
use CodeJuicer::DB;
use Digest::SHA qw(sha1_hex);
use Try::Tiny;
use File::Basename;
use List::MoreUtils qw(first_index);

our @DIRS = ();

sub _index {
  my ($dirname) = @_;
  unless (grep { /^$dirname$/ } @DIRS) {
    push @DIRS, $dirname;
  }
  first_index { $_ eq $dirname } @DIRS;
}

sub _cluster_dsm_graph_by_dir {
  my ($repository) = @_;
  my $id = $repository->{_id};
  my $graphs = CodeJuicer::DB->c('graphs')->find({ _id => $id });
  my $graph = $graphs->next;
  my %dsm = %{ $graph->{dsm} };
  my @nodes = @{ $dsm{nodes} };
  my @clustered_nodes = map {
    my $node = $_;
    $node->{directory} = dirname($node->{name});
    $node->{group} = _index($node->{directory});
    $node;
  } @nodes;
  $dsm{nodes} = \@clustered_nodes;
  CodeJuicer::DB->c('graphs')->update({ _id => $id }, { '$set' => {
    dsm => \%dsm
  }});
}

sub execute {
  my ($class, $type, $url) = @_;
  my $id = sha1_hex($url);
  try {
    my $repositories = CodeJuicer::DB->c('repositories')->find({ _id => $id });
    _cluster_dsm_graph_by_dir($repositories->next);
  }
  catch {
    CodeJuicer::DB->c('repositories')->update({ _id => $id }, { '$set' => {
      progress => 100,
      status => 'fail',
      error => $_,
    }});
    say "E: fail: $_";
  };
}

1;
