package CodeJuicer::Cmd::Command::add;
use Modern::Perl;
use Moose;
use Storable qw( freeze thaw );
use CodeJuicer;
use Gearman::Task;

extends qw(MooseX::App::Cmd::Command);
 
=head1 NAME

CodeJuicer::Cmd::Command::add - add repository to the queue

=cut

has url => (
  traits => [qw(Getopt)],
  isa => 'Str',
  is => 'rw',
  cmd_aliases => 'u',
  documentation => 'the url',
  required => 1,
);
 
has type => (
  traits => [qw(Getopt)],
  isa => 'Str',
  is => 'rw',
  cmd_aliases => 't',
  documentation => 'the type of url',
  required => 1,
);
 
sub execute {
  my ($self, $opt, $args) = @_;
  my $task = Gearman::Task->new(
    'add',
    \freeze([$self->type, $self->url]),
    {
      on_complete => sub {
        my %r = %{ thaw(${ $_[0] }) };
        say "task add complete";
        #$job->on_complete(@params, %r);
      },
      on_fail => sub {
        say "task add fail";
        #$job->on_fail;
      },
      on_retry => sub {
        my ($retry_count) = @_;
        say sprintf("[%d] trying task add again", $retry_count);
        #$job->on_retry;
      },
      timeout => 1,
      uniq => '-',
      retry_count => 2,
    }
  );
  $CodeJuicer::gearman->dispatch_background($task);
}

__PACKAGE__->meta->make_immutable;
