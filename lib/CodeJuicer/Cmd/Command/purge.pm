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

  #system('bin/codejuicer-worker start');
  #system('bin/codejuicer-observer start');
  #say "Starting Hypnotoad server.";
  #system('hypnotoad bin/codejuicer-web');
}

__PACKAGE__->meta->make_immutable;
