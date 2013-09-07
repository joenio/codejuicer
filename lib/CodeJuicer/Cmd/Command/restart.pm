package CodeJuicer::Cmd::Command::restart;
use Modern::Perl;
use Moose;

extends qw(MooseX::App::Cmd::Command);
 
=head1 NAME

CodeJuicer::Cmd::Command::restart - restart CodeJuicer's daemons

=cut

sub execute {
  my ($self, $opt, $args) = @_;
  my $app = $self->app;
  my $cmd;
  ($cmd) = $app->prepare_command('stop');
  $app->execute_command($cmd, $opt, @$args);
  ($cmd) = $app->prepare_command('start');
  $app->execute_command($cmd, $opt, @$args);
}

__PACKAGE__->meta->make_immutable;
