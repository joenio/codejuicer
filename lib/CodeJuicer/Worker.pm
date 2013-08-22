package CodeJuicer::Worker;
use Modern::Perl;
use Gearman::Worker;
use Storable qw( freeze thaw );
use CodeJuicer::Worker::Functions;

our $worker = Gearman::Worker->new;

sub work {
  $worker->work;
}

sub start {
  my ($self) = @_;
  say "starting worker, PID $$";
  $worker->job_servers("127.0.0.1:$CodeJuicer::GEARMAN_PORT");
  $self->register_function('add',    sub { CodeJuicer::Worker::Functions->add(@_)    });
  $self->register_function('update', sub { CodeJuicer::Worker::Functions->update(@_) });
  work() while 1;
}

sub register_function {
  my ($self, $name, $block) = @_;
  $worker->register_function($name => sub {
    my ($job) = @_;
    my (@params) = @{ thaw($job->arg) };
    say "working on " . $name;
    my $r = &$block(@params);
    return (ref $r ? freeze($r) : undef);
  });
}

1;
