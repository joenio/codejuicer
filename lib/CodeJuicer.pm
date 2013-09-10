package CodeJuicer;
use Modern::Perl;

=head1 NAME

CodeJuicer - extracts informations from the source code

=cut

use File::Share ':all';
our $SHAREDIR = dist_dir(__PACKAGE__);

use Gearman::Client;
our $GEARMAN_PORT = 4730;
our $gearman = Gearman::Client->new;
$gearman->job_servers("127.0.0.1:$GEARMAN_PORT");

use Gearman::Task;
use Storable qw( freeze thaw );

sub dispatch_gearman_task {
  my ($class, $function, $type, $url) = @_;
  my $task = Gearman::Task->new(
    $function,
    \freeze([$type, $url]),
    {
      on_complete => sub {
        my %r = %{ thaw(${ $_[0] }) };
        say "task $function complete";
      },
      on_fail => sub {
        say "task $function fail";
      },
      on_retry => sub {
        my ($retry_count) = @_;
        say sprintf("[%d] trying task $function again", $retry_count);
      },
      timeout => 1,
      uniq => '-',
      retry_count => 2,
    }
  );
  $gearman->dispatch_background($task);
}

use FindBin qw($Bin);
our $BINDIR = $ENV{CJ_BINDIR} // "$Bin";
our $RUNDIR = $ENV{CJ_RUNDIR} // "$Bin/../log";
our $LOGDIR = $ENV{CJ_LOGDIR} // "$Bin/../log";

1;
