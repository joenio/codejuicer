package CodeJuicer;
use Modern::Perl;

=head1 NAME

CodeJuicer - manager of source code analysis and data storage

=head1 DESCRIPTION

CodeJuicer is a manager of source code download and analysis, storage and
supply of data. It uses the L<Analizo|http://analizo.org> for source code
analysis and stores the information generated in a
L<MongoDB|http://www.mongodb.org> database in JSON format. All work is
performed in background and is managed by the
L<Gearman|http://www.gearman.org>, a distributed job queue system.

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

=head1 DESIGN

=begin html

<img src='../doc/design.png'/>

=end html

=head1 AUTHOR

Joenio Costa <joenio@colivre.coop.br>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Joenio Costa

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.
