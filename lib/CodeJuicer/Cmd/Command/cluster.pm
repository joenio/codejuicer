package CodeJuicer::Cmd::Command::cluster;
use Modern::Perl;
use Moose;
use CodeJuicer;

extends qw(MooseX::App::Cmd::Command);
 
=head1 NAME

CodeJuicer::Cmd::Command::cluster - add task to calculate graph clusters to the Gearman queue

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
  CodeJuicer->dispatch_gearman_task('cluster', $self->type, $self->url);
}

__PACKAGE__->meta->make_immutable;
