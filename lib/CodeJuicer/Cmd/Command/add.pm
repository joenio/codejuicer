package CodeJuicer::Cmd::Command::add;
use Modern::Perl;
use Moose;
use CodeJuicer;
use CodeJuicer::DB;

extends qw(MooseX::App::Cmd::Command);
 
=head1 NAME

CodeJuicer::Cmd::Command::add - enqueue function to fetch and analyse repository

=head1 DESCRIPTION

Fetch the repository, analyse source code and calculate clusters for the
graphs.

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
  if (CodeJuicer::DB->c('repositories')->count({ url => $self->url }) > 0) {
    warn "This URL already in the database!\n";
    warn "Try run `update` if you want to update it.\n";
  }
  else {
    CodeJuicer->dispatch_gearman_task('add', $self->type, $self->url);
    CodeJuicer->dispatch_gearman_task('cluster', $self->type, $self->url);
    say "Task to fetch and analyse repository added to the Gearman queue";
  }
}

__PACKAGE__->meta->make_immutable;

=head1 SEE ALSO

codejuicer(1)

=head1 AUTHOR

Joenio Costa <joenio@colivre.coop.br>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Joenio Costa

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.
