package CodeJuicer::Cmd::Command::purge;
use Modern::Perl;
use Moose;
use CodeJuicer;
use CodeJuicer::DB;
use IO::Prompt;
use File::Path qw(remove_tree);

extends qw(MooseX::App::Cmd::Command);
 
=head1 NAME

CodeJuicer::Cmd::Command::purge - drop database and all fetched repositories

=head1 DESCRIPTION

Delete any repository already fetched by CodeJuicer and drop all data in
the 'codejuicer' database.

=cut

sub execute {
  my ($self, $opt, $args) = @_;
  say "WARNING!";
  say "";
  say "It will destroy all data in your database and";
  say "delete all repositories fetched on the 'share'";
  say "directory.";
  say "";
  prompt "Are you sure want to continue? (yes/no) ";
  say "";
  if ($_ eq 'yes') {
    say "You are brave, going to clean all...";
    say "";
    print "dropping database...";
    $CodeJuicer::DB::db->drop;
    say " ok";
    print "deleting repositories...";
    remove_tree(grep { -d $_ } glob "$CodeJuicer::SHAREDIR/*");
    say " ok";
    say "";
    say "done!";
  }
  else {
    say "Aborting... good choice!";
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
