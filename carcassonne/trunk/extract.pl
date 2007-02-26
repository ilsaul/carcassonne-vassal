#!C:/Perl/bin/perl

use strict;

use Archive::Zip qw(:ERROR_CODES);
use YAML qw(LoadFile);

Archive::Zip::setErrorHandler( \&mydie );

my $CONFIG_YAML = 'config.yaml';

my $config = parse_yaml($CONFIG_YAML);

main();

sub main {
  print "extracting .mod file\n";
  clean();
  extract_module();
  #sleep 2;
}

sub extract_module {
  print "  extracting the main module\n";
  my $module_file = "$config->{name}-$config->{version}.mod";
  my $mod = new Archive::Zip($module_file);
  $mod->extractTree( '','./build/' );
}

sub clean {
  print "  cleaning the build directory\n";
  unlink glob("build/images/*.*");
  unlink glob("build/*");
  unlink glob("build/*");
}

sub select_files {
  return $_ !~ m/svn/;
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
