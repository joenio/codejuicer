package CodeJuicer::VCS::Driver::Git;
use Modern::Perl;
use base 'CodeJuicer::VCS::Driver';
use Git::Wrapper;

sub fetch {
  my ($self) = @_;
  my $git = Git::Wrapper->new('it_will_be_ignored');
  $git->RUN('clone', $self->url, $self->output);
  return 1;
}

sub update {
  my ($self) = @_;
  my $git = Git::Wrapper->new($self->input);
  $git->RUN('pull');
  return 1;
}

1;
