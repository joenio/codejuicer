package CodeJuicer::VCS::Driver::Git;
use Modern::Perl;
use base 'CodeJuicer::VCS::Driver';
use Git::Wrapper;

=head1 NAME

CodeJuicer::VCS::Driver::Git - driver for the Git system

=cut

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

=head1 SEE ALSO

L<CodeJuicer::VCS::Driver>.

=head1 AUTHOR

Joenio Costa <joenio@colivre.coop.br>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Joenio Costa

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.
