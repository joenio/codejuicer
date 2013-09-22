package CodeJuicer::Worker::Functions::update;
use Modern::Perl;
use CodeJuicer::VCS;
use CodeJuicer::DB;
use Digest::SHA qw(sha1_hex);
use Try::Tiny;
use Analizo::Batch::Job::Directories;
use DateTime;
use Graph::D3;

=head1 NAME

CodeJuicer::Worker::Functions::update - update URL, download, analyse, write in DB

=cut

sub execute {
  my ($class, $type, $url) = @_;
  my $id = my $input = sha1_hex($url);
  try {
    CodeJuicer::DB->c('repositories')->update({ _id => $id }, {
      '$set' => {
        status => 'updating',
        progress => 0,
      },
      '$unset' => {
        error => '',
      }
    });
    my $vcs = CodeJuicer::VCS->new($type);
    $vcs->update($url, $input) or die "error updating";
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
    CodeJuicer::DB->c('metrics')->update({ _id => $id }, { '$set' => {
      global_metrics => $global_metrics,
      modules_metrics => $modules_metrics,
    }});
    CodeJuicer::DB->c('repositories')->update({ _id => $id }, { '$set' => {
      progress => 75,
    }});
    my $model = $job->model;
    my $d3 = Graph::D3->new(graph => $model->graph);
    CodeJuicer::DB->c('graphs')->update({ _id => $id }, { '$set' => {
      dsm => $d3->force_directed_graph,
      callgraph => { not_implemented_yet => 1 },
    }});
    say "done";
    CodeJuicer::DB->c('repositories')->update({ _id => $id }, { '$set' => {
      updated_at => DateTime->now,
      status => 'updated',
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
