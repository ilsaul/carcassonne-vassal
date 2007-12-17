use strict;
my $FH;
open ($FH, "single.txt");
my $text = <$FH>;
close $FH;

open ($FH, ">multi.txt");
foreach my $num (2 .. 79) {
  my $num = sprintf("%0.3d",$num);
  my $newline = $text;
  $newline =~ s/XXX/$num/g;
  print $FH $newline;
}
close $FH;
