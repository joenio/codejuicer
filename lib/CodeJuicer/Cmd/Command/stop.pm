package CodeJuicer::Cmd::Command::stop;
use Modern::Perl;
use Moose;

extends qw(MooseX::App::Cmd::Command);
 
=head1 NAME

CodeJuicer::Cmd::Command::stop - stop CodeJuicer's daemons

=cut

sub execute {
  my ($self, $opt, $args) = @_;
  system('bin/codejuicer-worker stop');
  system('bin/codejuicer-observer stop');
  system('hypnotoad --stop bin/codejuicer-web');
}

__PACKAGE__->meta->make_immutable;
