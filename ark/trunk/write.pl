use strict;
use File::Copy;

__END__

foreach my $num (3 .. 62) {
  my $num = sprintf("%0.3d",$num);
  copy("ac002.png","ac$num.png");
}

my $FH;
open ($FH, "single");
my $text = <$FH>;
close $FH;

open ($FH, ">multi.txt");
foreach my $num (3 .. 62) {
  my $num = sprintf("%0.3d",$num);
  my $newline = $text;
  $newline =~ s/XXX/$num/g;
  print $FH $newline;
}
close $FH;
