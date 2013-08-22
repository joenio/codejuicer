package CodeJuicer::VCS::Driver;
use Modern::Perl;
use Moose;
use List::MoreUtils qw(uniq);
use File::Find;

has url => (is => 'rw');
has output => (is => 'rw');
has input => (is => 'rw');

sub _find_files {
  my ($search_path) = @_;
  my @files = ();
  local $_;
  File::Find::find({
    no_chdir => 1,
    follow_fast => 1,
    wanted => sub {
      return unless $File::Find::name =~ /\.pm$/;
      return unless $File::Find::name =~ m#/CodeJuicer/VCS/Driver/#;
      (my $path = $File::Find::name) =~ s#^\\./##;
      push @files, $path;
    }
  }, $search_path);
  return @files;
}

sub _find_drivers {
  my @SEARCHDIR = @_;
  my @files = ();
  foreach my $search_path (grep { -d $_ } @SEARCHDIR) {
    push @files, _find_files($search_path);
  }
  my @drivers = ();
  foreach my $file (@files) {
    $file =~ s#.*/CodeJuicer/VCS/Driver/##;
    $file =~ s#\.pm##;
    push @drivers, $file;
  }
  uniq @drivers;
}

sub available_drivers {
  unless (-e 'Makefile.PL' && -e 'dist.ini' && -e 'Build.PL') {
    pop @INC; # remove '.' when we are out of devel environment
  }
  my @drivers = _find_drivers(@INC);
  sort @drivers;
}

1;
