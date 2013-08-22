package CodeJuicer::VCS::Driver::Subversion;
use Modern::Perl;
use base 'CodeJuicer::VCS::Driver';
use SVN::Client;

sub fetch {
  my ($self) = @_;
  my $svn = SVN::Client->new();
  my $recursive = 1;
  $svn->checkout($self->url, $self->output, 'HEAD', $recursive);
  return 1;
}

sub update {
  my ($self) = @_;
  my $svn = SVN::Client->new();
  my $recursive = 1;
  $svn->update($self->input, 'HEAD', $recursive);
  return 1;
}

1;
