#!C:/Perl/bin/perl

use strict;

use Archive::Zip qw(:ERROR_CODES);
use File::Copy;
use File::Basename;
use Getopt::Long;
use YAML qw(LoadFile);

Archive::Zip::setErrorHandler( \&mydie );

my $DEFAULT_LANG_YAML = 'language.yaml';
my ( $LANG_YAML, $MODULE_NAME ) = ($DEFAULT_LANG_YAML);
my $parsed = GetOptions(
  "mod=s"  => \$MODULE_NAME,
  "lang=s" => \$LANG_YAML,
);

if ( !$parsed || !$MODULE_NAME || !$LANG_YAML ) {
  usage();
  exit 1;
}

my $lang = parse_yaml($LANG_YAML);

main();

sub main {
  verify_module();
  clean();
  build_langs();
}

sub usage {
  my $PROGRAM = basename($0);
  print <<"END_OF_USAGE";
  $PROGRAM was written by Tim Byrne
  
  This program translates VASSAL modules (coded a special way) into
  several modules using different languages.
  See http://carcassonne.locehilios.com/ for more details.

  USAGE:
  $PROGRAM --mod <module name>  [--lang <language file>]

    --mod
        The name of the module (without the .mod extension).
        The module will not be modified.
    --lang
        The name of language YAML file.  This defaults to $DEFAULT_LANG_YAML.

END_OF_USAGE
}

sub clean {
  print "removing any existing language modules\n";
  foreach my $l ( keys %{ $lang->{langs} } ) {
    unlink "$MODULE_NAME-$lang->{langs}->{$l}->{'abbr'}.mod";
  }
}

sub verify_module {
  unless ( -f "$MODULE_NAME.mod" ) {
    die "$MODULE_NAME.mod does not exist\n";
  }
}

sub build_langs {
  print "building language specific modules\n";
  foreach my $l ( keys %{ $lang->{langs} } ) {
    print "  building $l module\n";
    my $abbr      = $lang->{langs}->{$l}->{'abbr'};
    my $lang_file = "$MODULE_NAME-$abbr.mod";
    copy( "$MODULE_NAME.mod", $lang_file );
    my $mod               = new Archive::Zip($lang_file);
    my $working_buildfile = "buildfile.$$." . time . ".tmp";
    $mod->extractMember( 'buildFile', $working_buildfile );
    my @module_data;
    my $FH;
    open( $FH, $working_buildfile )
      || mydie("Can't read working buildfile $working_buildfile: $!");
    my @module_data = <$FH>;    ## slurp
    close $FH;
    open( $FH, ">$working_buildfile" )
      || mydie("Can't write working buildfile $working_buildfile: $!");
    foreach my $line (@module_data) {
      foreach my $p ( @{ $lang->{phrases} } ) {
        my ( $phrase, $replacement ) =
          ( quotemeta( $p->{phrase} ), $p->{$abbr} );
        $line =~ s/LANG_${phrase}/$replacement/g;
      }
      if ( $line =~ m/(LANG_.*)\b/ ) {
        mydie("No $abbr translation found for ->$1<-");
      }
      print $FH $line;
    }
    close $FH;
    $mod->updateMember( 'buildFile', $working_buildfile );
    $mod->overwrite();
    unlink $working_buildfile;
  }
}

sub parse_yaml {
  my ($file) = @_;
  my $yaml;
  eval { $yaml = LoadFile($file) };
  if ($@) {
    mydie("Can't parse $file: $@");
  }
  return $yaml;
}

sub mydie {
  die "@_\n";
}
