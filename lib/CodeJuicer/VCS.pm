package CodeJuicer::VCS;
use Modern::Perl;
use Moose;
use CodeJuicer::VCS::Driver;

=head1 NAME

CodeJuicer::VCS - abstraction layer to deal with version control systems

=head1 DESCRIPTION

Aimed to fetch and update source code hosted on version control systems
servers.

=head1 METHODS

=head2 new($driver_name)

Return a instance of L<CodeJuicer::VCS> to the given driver_name, driver_name
should be one of the supported drivers, L<CodeJuicer::VCS::Driver> is the
namespace for the drivers.

=cut

has driver => (is => 'ro');

around BUILDARGS => sub {
  my ($orig, $class, $driver_name) = @_;
  die unless $driver_name;
  my @available_drivers = CodeJuicer::VCS::Driver->available_drivers;
  unless (grep { $_ eq $driver_name } @available_drivers) {
    local $" = "\n";
    die "E: Unavailable driver!\n\n" .
        "Available drivers:\n" .
        "@available_drivers\n\n";
  }
  my $DRIVER_CLASS = "CodeJuicer::VCS::Driver::$driver_name";
  eval "use $DRIVER_CLASS;";
  $class->$orig(driver => $DRIVER_CLASS->new);
};


sub _repository_exists {
  my ($output) = @_;
  -e $output && -d $output;
}

=head2 fetch($url, $output)

Fetch the source code hosted on the given URL and save on output.

=cut

sub fetch {
  my ($self, $url, $output) = @_;
  $self->driver->url($url);
  $self->driver->output($output) if $output;
  if (_repository_exists($self->driver->output)) {
    warn sprintf("E: It seens that the repository '%s' already been fetched!\n", $self->driver->output);
    return 0;
  }
  print "I: Fetching...";
  return $self->driver->fetch;
}

=head2 update($url, $output)

Fetch the source code hosted on the given URL and save on the output directory.

=cut

sub update {
  my ($self, $url, $input) = @_;
  $self->driver->url($url);
  $self->driver->input($input) if $input;
  unless (_repository_exists($self->driver->input)) {
    warn sprintf("E: It seens that the repository '%s' was not fetched yet!\n", $self->driver->input);
    return 0;
  }
  print "I: Updating...";
  return $self->driver->update;
}

__PACKAGE__->meta->make_immutable;

=head1 SEE ALSO

L<CodeJuicer::VCS::Driver>

=head1 AUTHOR

Joenio Costa <joenio@colivre.coop.br>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Joenio Costa

This library is free software; you may redistribute it and/or modify
it under the same terms as Perl itself.
