package CodeJuicer::Worker::Functions;
use Modern::Perl;

sub _load {
  my ($klass) = @_;
  eval "use $klass;";
  if ($@) { die $@ };
  $klass;
}

our @FUNCTIONS = ('add', 'update', 'cluster');

sub each {
  my ($class, $code) = @_;
  for my $function (@FUNCTIONS) {
    my $function_class = "${class}::${function}";
    _load($function_class);
    &$code($function, sub { $function_class->execute(@_) });
  }
}

1;
