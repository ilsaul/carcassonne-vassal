use strict;
use Cwd;
use Win32::Process;
use YAML qw(LoadFile);

my $EDIT = 0;

if ($0 =~ m/edit/) {
  $EDIT++;
}

my $CONFIG_YAML = 'config.yaml';
my $template    = 'template.jnlp';
my $config      = parse_yaml($CONFIG_YAML);
my $cwd         = getcwd;

my $jnlp = "$cwd/launch-" . time . '.jnlp';
my $FH;
my $FH2;
if (open ($FH2,">$jnlp")) {
  if (open ($FH,$template)) {
    foreach my $line (<$FH>) {
      if ($line =~ m/\$\{arguments\}/) {
        $line = '';
        if ($EDIT) {
          $line .= "<argument>-edit</argument>\n";
        }
        $line .= "<argument>$cwd/$config->{name}-$config->{version}.mod</argument>\n";
      }
      print $FH2 $line;
    }
  }
}

my $p;
Win32::Process::Create(
  $p,
  $config->{javaws},
  "-Xnosplash $jnlp",
  0,
  NORMAL_PRIORITY_CLASS|CREATE_NO_WINDOW,
  ".") || mydie(ErrorReport());

END {
  sleep 5;
  unlink $jnlp;
}

sub ErrorReport{
  print Win32::FormatMessage( Win32::GetLastError() );
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
