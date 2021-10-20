#!/usr/bin/perl

#Selon http://mapki.com/wiki/Stitch_together_Google_Map_tiles


# download a bunch of google map tiles and stitch them together
# Shifty Death Effect Done by Noah Vawter in May, 2005.
# Computing Culture Groop, MIT Media Lab.
# Modified for compatibility with maps.7.js -> Mmaps.10.js by Ian (June 2005)

# with width 12
$sx = 8380;$sy = 12024;   # cambridge
#$sx = 5388;$sy = -729;   # boston downtown
#$sx = 5385;$sy = -726;   # boston

$w=10;
$h=10;

open(PEDG,">pedg.html");

for($yd=0;$yd<$h;$yd++)
{
    for($xd=0;$xd<$w;$xd++)
    {
	$x=int($sx+$xd-$w/2);
	$y=int($sy+$yd-$h/2);
	$localnem = "tile$x,$y.gif";

	# do we already have it locally?
	$val = open(CHECK,$localnem);
	if($val == 0){
	    # http://mt.google.com/mt?v=w2.4&x=4190&y=6012&zoom=3
	    #   523  wget "http://mt.google.com/mt?v=.38&x=5376&y=-730&zoom=2"
	    $req="http://mt.google.com/";
	    $nem="mt?v=w2.4&x=$x&y=$y&zoom=2";
	    $url = $req . $nem;
	    print "$url\n";
	    $cmd1="wget \"$url\" ";
	    print "$cmd1\n";
	    system($cmd1);
	    $nem =~ s/\?/@/;
	    $cmd2="mv \"$nem\" $localnem";
	    print "$cmd2\n";
	    system($cmd2);
	}

	print PEDG "<img src=$localnem>\n";
    }
}

# concatenate horizontal maps
# convert  tile005000.gif  -page +129+0 tile006000.gif -page +258+0 tile007000.gif -mosaic o.gif

for($yd=0;$yd<$h;$yd++)
{
    $cmd3 = "convert ";

    for($xd=0;$xd<$w;$xd++)
    {
	$x=int($sx+$xd-$w/2);
	$y=int($sy+$yd-$h/2);
	$localnem = "tile$x,$y.gif";
	
	$xsh = $xd*128;
	$ysh = $yd*128;
	$cmd3 .= "$localnem ";
    }

    $cmd3 .= "+append tmp$yd.gif";
    print "$cmd3\n";
    system($cmd3);
}

# concatenate horizontal strips
$cmd4 = "convert ";

for($yd=0;$yd<$h;$yd++)
{
    $localnem = "tmp$yd.gif";
    $cmd4 .= "$localnem ";
}

$cmd4 .= "-append output.gif";
print "$cmd4\n";
system($cmd4);

