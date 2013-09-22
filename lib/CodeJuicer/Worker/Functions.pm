package CodeJuicer::Worker::Functions;
use Modern::Perl;

=head1 NAME

CodeJuicer::Worker::Functions - load Perl modules for the CodeJuicer::Worker

=cut

sub _load {
  my ($klass) = @_;
  eval "use $klass;";
  if ($@) { die $@ };
  $klass;
}

=head1 METHODS

=head1 each(sub { ... })

Load each CodeJuicer::Worker::Function Perl module and execute the codeblock
for each function, passing the function name and a codeblock calling the
`execute()` method in the loaded module.

=cut

# TODO
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

=head1 AUTHOR

Joenio Costa <joenio@colivre.coop.br>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Joenio Costa

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.
