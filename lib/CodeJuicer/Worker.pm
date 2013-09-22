package CodeJuicer::Worker;
use Modern::Perl;
use Gearman::Worker;
use Storable qw( freeze thaw );
use CodeJuicer::Worker::Functions;

=head1 NAME

CodeJuicer::Worker - manage and provide access to the Gearman system

=cut

our $worker = Gearman::Worker->new;

sub work {
  $worker->work;
}

sub start {
  my ($self) = @_;
  say "starting worker, PID $$";
  $worker->job_servers("127.0.0.1:$CodeJuicer::GEARMAN_PORT");
  CodeJuicer::Worker::Functions->each(sub {
    my ($name, $code) = @_;
    $self->register_function($name, sub { &$code(@_) });
  });
  work() while 1;
}

sub register_function {
  my ($self, $name, $block) = @_;
  $worker->register_function($name => sub {
    my ($job) = @_;
    my (@params) = @{ thaw($job->arg) };
    print "working on $name";
    my $r = &$block(@params);
    say "done $name";
    return (ref $r ? freeze($r) : undef);
  });
}

1;

=head1 SEE ALSO

codejuicer-worker(1)

=head1 AUTHOR

Joenio Costa <joenio@colivre.coop.br>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Joenio Costa

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.
