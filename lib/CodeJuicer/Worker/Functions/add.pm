package CodeJuicer::Worker::Functions::add;
use Modern::Perl;
use CodeJuicer::VCS;
use CodeJuicer::DB;
use Digest::SHA qw(sha1_hex);
use Try::Tiny;
use Analizo::Batch::Job::Directories;
use DateTime;
use Graph::D3;

=head1 NAME

CodeJuicer::Worker::Functions::add - add URL, download, analyse, write in DB

=cut

sub execute {
  my ($class, $type, $url) = @_;
  my $id = my $output = my $input = sha1_hex($url);
  try {
    CodeJuicer::DB->c('repositories')->insert({
      _id => $id,
      type => $type,
      url => $url,
      status => 'adding',
      progress => 0,
    });
    my $vcs = CodeJuicer::VCS->new($type);
    $vcs->fetch($url, $output) or die "error fetching";
    say "done";
    CodeJuicer::DB->c('repositories')->update({ _id => $id }, { '$set' => {
      progress => 50,
    }});
    print "I: Analyzing...";
    my $job = Analizo::Batch::Job::Directories->new($input);
    $job->execute();
    my $metrics = $job->metrics;
    $metrics->_collect_and_combine_module_metrics;
    my $global_metrics = $metrics->global_metrics->report;
    my $modules_metrics = $metrics->module_data;
    CodeJuicer::DB->c('metrics')->insert({
      _id => $id,
      global_metrics => $global_metrics,
      modules_metrics => $modules_metrics,
    });
    CodeJuicer::DB->c('repositories')->update({ _id => $id }, { '$set' => {
      progress => 75,
    }});
    my $model = $job->model;
    my $d3 = Graph::D3->new(graph => $model->graph);
    CodeJuicer::DB->c('graphs')->insert({
      _id => $id,
      dsm => $d3->force_directed_graph,
      callgraph => { not_implemented_yet => 1 },
    });
    say "done";
    CodeJuicer::DB->c('repositories')->update({ _id => $id }, { '$set' => {
      added_at => DateTime->now,
      status => 'added',
      progress => 100,
    }});
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

=head1 AUTHOR

Joenio Costa <joenio@colivre.coop.br>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Joenio Costa

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.
