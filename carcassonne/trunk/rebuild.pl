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

sub build_guide {
  print "  rebuilding the player guide\n";
  my $guide_file = "Player_Guide";
  my $guide = new Archive::Zip;
  $guide->addTree( './guidesrc', '', \&select_files );
  $guide->writeToFileNamed( $guide_file );
  return $guide_file;
}

sub build_module {
  print "  rebuilding the main module\n";
  my $module_file = "$config->{name}-$config->{version}.mod";
  my $mod = new Archive::Zip;
  $mod->addTree( './build', '', \&select_files );
  if (-d "$config->{name}-java/bin/com") {
    $mod->addTree( "$config->{name}-java/bin/com", 'com', \&select_files_class );
  }
  if (-d "guidesrc") {
    my $guide_file  = build_guide();
    $mod->addDirectory( 'help' );
    $mod->addFile( 'Player_Guide', 'help/Player_Guide' );
  }
  $mod->writeToFileNamed( $module_file );
  unlink 'Player_Guide';
  return $module_file;
}

sub clean {
  print "  removing any existing files\n";
  unlink glob("$config->{name}*.mod");
  unlink glob("Player_Guide");
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
