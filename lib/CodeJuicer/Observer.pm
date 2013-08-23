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

sub start {
  say "starting observer, PID $$";
  while (1) {
    my $repositories = CodeJuicer::DB->c('repositories')->find();
    while (my $repository = $repositories->next) {
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
