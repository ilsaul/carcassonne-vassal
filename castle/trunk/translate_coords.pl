use strict;
use File::Copy;
__END__
my $NEW;
open ($NEW, ">new.txt");

my $FH;
open ($FH, "stage2.txt");
while (my $line = <$FH>) {
  if ($line =~ m/path="CO:(\d+),(\d+)"/) {
    my ($x,$y) = ($1,$2);
    my $shape =
      ($x-1) . "," . ($y-1) . ";" . 
      ($x+1) . "," . ($y-1) . ";" . 
      ($x+1) . "," . ($y+1) . ";" . 
      ($x-1) . "," . ($y+1)
    ;
    $line =~ s/CO:\d+,\d+/$shape/;
  }
  print $NEW $line;
}
close $FH;
close $NEW;

__END__

<VASSAL.build.module.map.boardPicker.board.mapgrid.Zone locationFormat="$name$" name="12" path="CO:124,760" useParentGrid="true"/>
<VASSAL.build.module.map.boardPicker.board.mapgrid.Zone locationFormat="$name$" name="12" path="123,759;125,759;125,761;123,761" useParentGrid="true"/>
<VASSAL.build.module.map.boardPicker.board.Region name="12" originx="124" originy="760"/>
