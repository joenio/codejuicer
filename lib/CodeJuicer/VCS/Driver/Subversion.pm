package CodeJuicer::VCS::Driver::Subversion;
use Modern::Perl;
use base 'CodeJuicer::VCS::Driver';
use SVN::Client;

=head1 NAME

CodeJuicer::VCS::Driver::Subversion - driver for the Subversion system

=cut

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

=head1 SEE ALSO

L<CodeJuicer::VCS::Driver>.

=head1 AUTHOR

Joenio Costa <joenio@colivre.coop.br>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Joenio Costa

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.
