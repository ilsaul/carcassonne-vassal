#!C:/Perl/bin/perl

use strict;

use Archive::Zip qw(:ERROR_CODES);
use File::Copy;
use YAML qw(LoadFile);

Archive::Zip::setErrorHandler( \&mydie );

my $CONFIG_YAML = 'config.yaml';
my $LANG_YAML   = 'language.yaml';

my $config = parse_yaml($CONFIG_YAML);
my $lang   = parse_yaml($LANG_YAML);

main();

sub main {
  print "Rebuilding .mod files\n";
  clean();
  my $module_file = build_module();
  build_langs($module_file);
  #sleep 2;
}

sub build_module {
  print "  rebuilding the main module\n";
  my $module_file = "$config->{name}-$config->{version}.mod";
  my $mod = new Archive::Zip;
  $mod->addTree( './build', '', \&select_files );
  $mod->writeToFileNamed( $module_file );
  return $module_file;
}

sub clean {
  print "  removing any existing files\n";
  unlink glob("$config->{name}*.mod");
}

sub build_langs {
  print "  building language specific modules\n";
  my ($module_file) = @_;
  foreach my $l (keys %{ $lang->{langs} }) {
      print "    building $l module\n";
      my $abbr = $lang->{langs}->{$l}->{'abbr'};
      my $lang_file = "$config->{name}-$config->{version}-$abbr.mod";
      copy($module_file,$lang_file);
      my $mod = new Archive::Zip($lang_file);
      my $working_buildfile = "buildfile.$$." . time . ".tmp";
      $mod->extractMember('buildFile',$working_buildfile);
      my @module_data;
      my $FH;
      open ($FH,$working_buildfile) || mydie("Can't read working buildfile $working_buildfile: $!");
      my @module_data = <$FH>; ## slurp
      close $FH;
      open ($FH,">$working_buildfile") || mydie("Can't write working buildfile $working_buildfile: $!");

      foreach my $line (@module_data) {
        foreach my $p (@{ $lang->{phrases} }) {
          my ($phrase,$replacement) = (quotemeta($p->{phrase}),$p->{$abbr});
          $line =~ s/LANG_${phrase}/$replacement/g;
        }
        if ($line =~ m/(LANG_.*)\b/) {
          mydie("No $abbr translation found for ->$1<-");
        }
        print $FH $line;
      }
      close $FH;
      $mod->updateMember('buildFile',$working_buildfile);
      $mod->overwrite();
      unlink $working_buildfile;
  }
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
