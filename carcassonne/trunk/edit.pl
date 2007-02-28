use strict;
use Cwd;
use Win32::Process;
use YAML qw(LoadFile);

my $CONFIG_YAML = 'config.yaml';
my $config = parse_yaml($CONFIG_YAML);
my $lang = $ARGV[0] || '';
$lang = "-$lang" if $lang;

my $cwd = getcwd;
my $p;
Win32::Process::Create(
  $p,
  "C:/WINDOWS/system32/cmd.exe",
  "/C c:\\WINDOWS\\system32\\java.exe -jar C:\\vassal\\runVassal.jar -edit $cwd/$config->{name}-$config->{version}${lang}.mod",
  0,
  NORMAL_PRIORITY_CLASS|CREATE_NO_WINDOW,
  ".") || mydie(ErrorReport());

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

