<?php 
# Perl by Noah Vawter in May, 2005.
# PHP by noname, Jun 2006. My first PHP program (copy&paste) :-/
# Needs menu image... using google logo :-/
#Constantes, Variables y cabecera HTML
$filename = substr(strrchr($PHP_SELF,'/'),1); if ($filename=="") {$filename=substr(strrchr($_SERVER["PHP_SELF"],'/'),1);}
$zoomlevels = 17; # Zoom en el que toda la tierra ocupa un tile
$tw = 256;        # Pixels por cada tile (cuadrado de 256x256)

#  Parametros - Coordenadas y zoom # Comprueba parametros
$z = $_GET['z'];  # ZOOM entre 16(mundo) y 0(calle)
$pda=$_GET['resize'];; if ($pda=="") {$pda=100;}
$frames=$_GET['frames'];; if ($frames=="") {$frames=1;}
$minlat = $_GET['lat'];
$minlon = $_GET['lon'];
if ($z=="") {$z = 12;} if ($z<0) {$z = 0;}
# Guarda originales para menu botones
$guardalat=$minlat; $guardalon=$minlon;
if ($z>15) {$z = 16; $minlon =1; $minlat = 1;}
$zoomplus=$z-1; $zoomminus=$z+1;
if ($minlat=="") { $minlat = 41;}
if ($minlon=="") { $minlon = -4;}
if ($pda>100) {$pda=100;}if ($pda<30) {$pda=30;}
$resize=$pda/100;

# Pasa coordenadas a tiles y pixels
list ($tltx, $tlty, $pixelx, $pixely) = coord2tile($minlat, $minlon, $z);
$tltx--;       # Me gusta el del centro. Un pasito patras. Dos pasitos palante
$tlty--;
$brtx=$tltx+2;
$brty=$tlty+2;

#primer y ultimo pixel de los tiles (del primer y ultimo tile)
list ($tlpx, $tlpy, $foo, $bar) =  tile2pixels($tltx, $tlty, $z);
list ($foo, $bar, $brpx, $brpy) =  tile2pixels($brtx, $brty, $z);

#Coordenadas de las esquinas UpLeft - DownRigth
list ($minlat, $minlon) = pixel2coord($tlpx, $tlpy, $z);
list ($maxlat, $maxlon) = pixel2coord($brpx, $brpy, $z);
$minlat = round($minlat,6); $minlon = round($minlon,6);
$maxlat = round($maxlat,6); $maxlon = round($maxlon,6);

echo '<HTML><HEAD><title>Gmaps NoScript</title></HEAD><BODY>';

# Botoncitos de menu
$spda=13+round(20*$resize);
$z1=$pda+10;$z2=$pda-10;

if ($frames==1) {$cframes=0;} else {$cframes=1;}
if ($frames==1) {echo '<div  style="z-index: 11 ;position: absolute; left: 0px; top: 0px; overflow:hidden; scrollbars=no; padding: 0px;height: 64px;">'."\n";}

echo '<img src="http://www.google.com/intl/en/images/logo.gif" width=191px height=62px border=0 usemap="#menu">'."\n";
######################### Image Menu format:
# r+# le# up# ra# z+# Fr# resize+/-   Zoom +/-
######################### Up/down
# r-#   # dw#   # z-#     Left / right
#####   #####   #####     Switch Frames/NoFrames

echo '<MAP NAME="menu">'."\n";
echo '<AREA ALT="Size+" SHAPE="rect" COORDS=" 0, 0,30,31" href="'.$filename.'?lat='.$guardalat.'&lon='.$guardalon.'&z='.$z.'&resize='.$z1.'&frames='.$frames.'">'."\n";
echo '<AREA ALT="Size-" SHAPE="rect" COORDS=" 0,32,32,62" href="'.$filename.'?lat='.$guardalat.'&lon='.$guardalon.'&z='.$z.'&resize='.$z2.'&frames='.$frames.'">'."\n";
    list($tmplat, $tmplon) = pixel2coord(($pixelx+127),($pixely), $z);$tmplat = round($tmplat,6);$tmplon = round($tmplon,6);
echo '<AREA ALT="Left" SHAPE="rect" COORDS="33, 0,63,31" href="'.$filename.'?lat='.$tmplat.'&lon='.$tmplon.'&z='.$z.'&resize='.$pda.'&frames='.$frames.'">'."\n";
    list($tmplat, $tmplon) = pixel2coord(($pixelx-127),($pixely), $z);$tmplat = round($tmplat,6);$tmplon = round($tmplon,6);
echo '<AREA ALT="Right" SHAPE="rect" COORDS="96,0,127,31" href="'.$filename.'?lat='.$tmplat.'&lon='.$tmplon.'&z='.$z.'&resize='.$pda.'&frames='.$frames.'">'."\n";
    list($tmplat, $tmplon) = pixel2coord(($pixelx),($pixely+127), $z);$tmplat = round($tmplat,6);$tmplon = round($tmplon,6);
echo '<AREA ALT="Up" SHAPE="rect" COORDS="62,0,94,31" href="'.$filename.'?lat='.$tmplat.'&lon='.$tmplon.'&z='.$z.'&resize='.$pda.'&frames='.$frames.'">'."\n";
    list($tmplat, $tmplon) = pixel2coord(($pixelx),($pixely-127), $z);$tmplat = round($tmplat,6);$tmplon = round($tmplon,6);
echo '<AREA ALT="Down" SHAPE="rect" COORDS="65,32,93,62" href="'.$filename.'?lat='.$tmplat.'&lon='.$tmplon.'&z='.$z.'&resize='.$pda.'&frames='.$frames.'">'."\n";
echo '<AREA ALT="Zoom+" SHAPE="rect" COORDS="129,0,158,31" href="'.$filename.'?lat='.$guardalat.'&lon='.$guardalon.'&z='.$zoomplus.'&resize='.$pda.'&frames='.$frames.'">'."\n";
echo '<AREA ALT="Zoom-" SHAPE="rect" COORDS="128,32,158,62" href="'.$filename.'?lat='.$guardalat.'&lon='.$guardalon.'&z='.$zoomminus.'&resize='.$pda.'&frames='.$frames.'">'."\n";
echo '<AREA ALT="Frames" SHAPE="rect" COORDS="161,0,191,31" href="'.$filename.'?lat='.$guardalat.'&lon='.$guardalon.'&z='.$z.'&resize='.$pda.'&frames='.$cframes.'">'."\n";
echo '<AREA ALT="About" SHAPE="rect" COORDS="161,34,190,62" href="about.php">'."\n";
echo '<AREA SHAPE="default">'."\n";

if ($frames==1) {
	echo "</div>";

# Desplazamiento de la ventana para centrar coordenadas
$dx=(round(-($pixelx-$tlpx)+255)*$resize)+$spda;
$dy=round(-($pixely-$tlpy)+255)*$resize;
if ($z>15) {$dx = 1; $dy =1; $tlty++ ;} # Con zoom maximo no hace falta
echo '<div  style="z-index: 0; position: absolute; left: 0px; top: 0px; overflow:hidden; scrollbars=no; padding: 0px;height: 512px; width: 512px;">'."\n";
echo '<div  style="z-indez: 1; position: absolute; left: '.$dx.'px; top: '.$dy.'px; overflow:hidden; scrollbars=no; padding: 0px;">'."\n";
    } # End noframes


# Para poder ver en mininavegador usamos una tabla
echo "<TABLE BORDER=0 FRAMEBORDER=0 FRAMESPACING=0 CELLSPACING=0 CELLPADDING=0>\n";
$server=0; #Hay 4 servidores de los que cargar los tiles.

for ($y = $tlty; $y <= $brty; $y++) {
    echo "<TR>\n";
    for ($x = $tltx; $x <= $brtx; $x++) {
    	$server=($server+1)%4;
        $req="http://mt".$server.".google.com/";
        $nem="mt?n=404&v=w2.12&x=$x&y=$y&zoom=$z";
	$name="tile".$x."x".$y."x".$z;
	$url = $req . $nem;
	$px=($x-$tltx)*$tw;
	$py=($y-$tlty)*$tw;
	$zz=$z-1;
        list ($tlpxx, $tlpyy, $brpxx, $brpyy) =  tile2pixels($x, $y, $z);
        #pixels del centro
        $ccpxx=round(($tlpxx+$brpxx)/2);
        $ccpyy=round(($tlpyy+$brpyy)/2);
        # Guardamos arriba abajo derecha izquierda y centro para usar con el menu
        $pasay=$brty-$y; $pasax=$brtx-$x;
        if (($x==0) and ($y==0)) {
            list($tmplat, $tmplon) = pixel2coord($ccpxx,$ccpyy, $z);
            $tmplat = round($tmplat,6);$tmplon = round($tmplon,6);
            $centro='HREF="'.$filename.'?lat='.$tmplat.'&lon='.$tmplon.'&z='.$zz.'">'."\n";
            }

# Creando mapa en las imagenes
{ echo '<MAP NAME="'.$name.'">'."\n";
        # Centro del sector superior izquierdo del tile
        list($tmplat, $tmplon) = pixel2coord(round(($tlpxx+$ccpxx)/2),round(($tlpyy+$ccpyy)/2), $z);
        $tmplat = round($tmplat,6);$tmplon = round($tmplon,6);
        echo '<AREA SHAPE="rect" COORDS="0,0,127,127" HREF="'.$filename.'?lat='.$tmplat.'&lon='.$tmplon.'&z='.$zz.'&resize='.$pda.'&frames='.$frames.'">'."\n";
        # Centro del sector superior derecho del tile
        list($tmplat, $tmplon) = pixel2coord(round(($ccpxx+$brpxx)/2),round(($tlpyy+$ccpyy)/2), $z);
        $tmplat = round($tmplat,6);$tmplon = round($tmplon,6);
        echo '<AREA SHAPE="rect" COORDS="128,0,255,127" HREF="'.$filename.'?lat='.$tmplat.'&lon='.$tmplon.'&z='.$zz.'&resize='.$pda.'&frames='.$frames.'">'."\n";
        # Centro del sector inferior izquierdo del tile
        list($tmplat, $tmplon) = pixel2coord(round(($tlpxx+$ccpxx)/2),round(($ccpyy+$brpyy)/2), $z);
        $tmplat = round($tmplat,6);$tmplon = round($tmplon,6);
        echo '<AREA SHAPE="rect" COORDS="0,128,128,255" HREF="'.$filename.'?lat='.$tmplat.'&lon='.$tmplon.'&z='.$zz.'&resize='.$pda.'&frames='.$frames.'">'."\n";
        # Centro del sector inferior derecho del tile
        list($tmplat, $tmplon) = pixel2coord(round(($ccpxx+$brpxx)/2),round(($ccpyy+$brpyy)/2), $z);
        $tmplat = round($tmplat,6);$tmplon = round($tmplon,6);
        echo '<AREA SHAPE="rect" COORDS="128,128,255,255" HREF="'.$filename.'?lat='.$tmplat.'&lon='.$tmplon.'&z='.$zz.'&resize='.$pda.'&frames='.$frames.'">'."\n";
  echo "</MAP>\n"; }
	$spda=round(256*$resize);
	echo "<TD>";
	echo '<IMG HEIGHT='.$spda." width=".$spda.' BORDER=0 src="'.$url.'" '.'USEMAP="#'.$name.'">';
	echo "</TD>\n";
	}

echo "</TR>\n";
}
echo "</TABLE>\n";

# Entra flotante y redondea positivos y negativos hacia cero
function myint($f) {
    if ($f < 0) {
	return ceil($f);
    } else {
	return floor($f);
    }
}
# Entra Lat-Lon-Zoom y sale los tiles a los que corresponden
# Tambien devuelve las coordenadas en pixels para ese zoom.
function coord2tile($lat, $long, $z) {
# Given coordinates and zoom level, return the address of the tile which
# contains them, as well as their pixel address on the full map.
	global $zoomlevels, $tw;
	$pi=3.14159265358979323846;

    $mapsize = pow(2,(($zoomlevels + (log($tw)/log(2)))-$z));
    $origin = $mapsize / 2;

    $longdeg = abs(-180 - $long);
    $longppd = $mapsize / 360;
    $longppdrad = $mapsize/(2*$pi);
    $pixelx = $longdeg * $longppd;
    $longtiles = $pixelx  / $tw;

    $tilex = myint($longtiles);

    $e = sin($lat*($pi/180));
    if ($e>0.9999) { $e=0.9999; }
    if ($e<-0.9999) { $e=-0.9999; }

    $pixely = $origin + 0.5*log((1+$e)/(1-$e)) * (-$longppdrad);
    $tiley = myint($pixely / $tw);

    $pixely = round($pixely);
    $pixelx = round($pixelx);

    return array ($tilex, $tiley, $pixelx, $pixely);
}
# Entra coordenadas pixelxy y zoom. Devuelve coordenadas Lat-Lon
function pixel2coord($x, $y, $z) {
# Given pixel address from the full map at zoom level Z, return the
# latitude and longitude of that address.
global $tw, $zoomlevels;
$pi=3.141592653589793;
    $mapsize = pow(2,(($zoomlevels + (log($tw)/log(2)))-$z));
    $origin = $mapsize / 2;
    $longdpp = 360 /$mapsize;
    $longpprad = $mapsize / (2*$pi);

    $long = -180 + ($x * $longdpp);

    $e = ($y - $origin) /  (-$longpprad);
    if ($e>0.9999) { $e=0.9999; }
    if ($e<-0.9999) { $e=-0.9999; }
    $lat = (2*atan(exp($e))-($pi/2)) / ($pi/180);

    return array ($lat, $long);
}
# Entra tilexy y devuelve pixels xy de las esquinas UpLeft y DownRight.
function tile2pixels($tilex, $tiley, $z){
# Given a tile and zoom level, return the minimum and maximum x and y pixel on
# the  full map
    global $tw;
    $minx = $tilex*$tw;
    $miny = $tiley*$tw;

    $maxx = (($tilex+1)*$tw)-1;
    $maxy = (($tiley+1)*$tw)-1;

    return array ($minx, $miny, $maxx, $maxy);
}

echo "</BODY></HTML>";
?>

