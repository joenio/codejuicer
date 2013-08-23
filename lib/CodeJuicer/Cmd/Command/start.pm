package CodeJuicer::Cmd::Command::start;
use Modern::Perl;
use Moose;

extends qw(MooseX::App::Cmd::Command);
 
=head1 NAME

CodeJuicer::Cmd::Command::start - start daemons

=cut

sub execute {
  my ($self, $opt, $args) = @_;
  system('bin/codejuicer-worker start');
  system('bin/codejuicer-observer start');
  say "Starting Hypnotoad server.";
  system('hypnotoad bin/codejuicer-web');
}

__PACKAGE__->meta->make_immutable;
