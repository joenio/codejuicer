package CodeJuicer::Observer;
use Modern::Perl;
use CodeJuicer::DB;
use DateTime;
use CodeJuicer::Cmd;

our $INTERVAL = 1 * 60 * 60; # 1 hour
our $EXPIRES = 24 * 60 * 60; # 24 hours

sub _needs_update {
  my ($repository) = @_;
  my $date = $repository->{"$repository->{status}_at"};
  return unless $date;
  my $expires_at = $date->add(seconds => $EXPIRES);
  return DateTime->compare($date, $expires_at) == 1;
}

our @GROUPS = ();
use File::Basename;
use List::MoreUtils qw(first_index);

sub _group_number {
  my ($name) = @_;
  my $dir = dirname($name);
  print $dir;
  unless (grep { /^$dir$/ } @GROUPS) {
    print " not in array GROUPS";
    push @GROUPS, $dir;
  }
  my $index = first_index { $_ eq $dir } @GROUPS;
  return ($index, $dir);
}

sub _cluster_dsm_by_folder {
  my ($repository) = @_;
  my $id = $repository->{_id};
  my $graphs = CodeJuicer::DB->c('graphs')->find({ _id => $id });
  my $graph = $graphs->next;
  my %dsm = %{ $graph->{dsm} };
  my @nodes = @{ $dsm{nodes} };
  my @groups = ();
  my @clustered_nodes = map {
    my $node = $_;
    my $name = $node->{name};
    my ($group_number, $group_name) = _group_number($name);
    print " index = $group_number";
    say "";
    $groups[$group_number] = $group_name;
    {group => $group_number, name => $name};
  } @nodes;
  $dsm{nodes} = \@clustered_nodes;
  $dsm{groups} = \@groups;
  CodeJuicer::DB->c('graphs')->update({ _id => $id }, { '$set' => {
    dsm_cluster1 => \%dsm
  }});
}

sub start {
  say "starting observer, PID $$";
  while (1) {
    my $repositories = CodeJuicer::DB->c('repositories')->find();
    while (my $repository = $repositories->next) {

      _cluster_dsm_by_folder($repository);

      if (_needs_update($repository)) {
        my $app = CodeJuicer::Cmd->new;
        say $repository->{url}, " needs update";
        my ($cmd, $opt, @args) = $app->prepare_command('update', '--type', $repository->{type}, '--url', $repository->{url});
        $app->execute_command($cmd, $opt, @args);
      }
    }
    sleep $INTERVAL;
  }
}

1;
