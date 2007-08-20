#!C:/Perl/bin/perl

use strict;

use Archive::Zip qw(:ERROR_CODES);
use File::Copy;
use YAML qw(LoadFile);

Archive::Zip::setErrorHandler( \&mydie );

my $CONFIG_YAML = 'config.yaml';

my $config = parse_yaml($CONFIG_YAML);

main();

sub main {
  print "Rebuilding .mod file\n";
  clean();
  my $module_file = build_module();
  #sleep 2;
}

sub build_module {
  print "  rebuilding the main module\n";
  my $module_file = "$config->{name}-$config->{version}.mod";
  my $mod = new Archive::Zip;
  $mod->addTree( './build', '', \&select_files );
  if (-d "$config->{name}-java/bin/com") {
    $mod->addTree( "$config->{name}-java/bin/com", 'com', \&select_files_class );
  }
  $mod->writeToFileNamed( $module_file );
  return $module_file;
}

sub clean {
  print "  removing any existing files\n";
  unlink glob("$config->{name}*.mod");
}

sub select_files {
  return $_ !~ m/svn/;
}

sub select_files_class {
  if ( $_ =~ m/(svn)/ ) {
    return 0;
  }
  elsif ( $_ =~ m/.+\.class/ ) {
    return 1;
  }
  return 0;
}

sub parse_yaml {
  my ($file) = @_;
  my $yaml;
  eval {$yaml = LoadFile($file)};
  if ($@) {
    mydie("Can't parse $file: $@");
  }
  return $yaml;
}

sub mydie {
  print "@_\n";
  sleep 5;
  die;
}

END {
  foreach my $badbuild (glob('buildfile.*')) {
    unlink $badbuild;
  }
}
