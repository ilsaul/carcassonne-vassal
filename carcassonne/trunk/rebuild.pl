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

sub build_langs {
  print "  building language specific modules\n";
  my $matched = {};
  my ($module_file) = @_;
  foreach my $l (keys %{ $lang->{langs} }) {
    print "    building $l module\n";
    my $abbr = $lang->{langs}->{$l}->{abbr};
    my $lang_file = "$config->{name}-$config->{version}-$abbr.mod";
    copy($module_file,$lang_file);
    my $mod = new Archive::Zip($lang_file);
    my $working_buildfile = "buildfile.$$." . time . ".tmp";
    print "      extracting buildFile\n";
    $mod->extractMember('buildFile',$working_buildfile);
    my @module_data;
    my $FH;
    open ($FH,$working_buildfile) || mydie("Can't read working buildfile $working_buildfile: $!");
    my @module_data = <$FH>; ## slurp
    close $FH;
    open ($FH,">$working_buildfile") || mydie("Can't write working buildfile $working_buildfile: $!");

    print "      updating phrases\n";
    foreach my $line (@module_data) {
      foreach my $p (sort by_phrase_length @{ $lang->{phrases} }) {
        my ($phrase,$replacement) = (quotemeta($p->{phrase}),$p->{$abbr});
        if ($line =~ s/LANG_${phrase}/$replacement/g) {
          $matched->{$p->{phrase}}++;
        }
      }
      if ($line =~ m/(LANG_.*)\b/) {
        mydie("No $abbr translation found for ->$1<-");
      }
      print $FH $line;
    }
    close $FH;
    print "      updating buildFile\n";
    $mod->updateMember('buildFile',$working_buildfile);
    $mod->overwrite();
    #print "      extracting info-$abbr\n";
    #$mod = new Archive::Zip($lang_file);
    #$mod->extractMember("info-$abbr",$working_buildfile);
    #print "      updating info\n";
    #$mod->updateMember('info',$working_buildfile);
    #$mod->overwrite();
    unlink $working_buildfile;
  }
  my $pause = 0;
  foreach my $p (@{ $lang->{phrases} }) {
    if (! $matched->{$p->{phrase}}) {
      print "Never matched: $p->{phrase}\n";
      $pause++;
    }
  }
  sleep 2 if $pause;
}

sub by_phrase_length {
  return length($b->{phrase}) <=> length($a->{phrase});
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
