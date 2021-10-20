#!/bin/sh
#traitement des photos du répertoire courant:
# au préalable, les images doivent être correctement tournées.
#
# 1/ geotaggage à partir d'un fichier
#      ~/gps/xtract_tracks_currentyear.gpx
#    préalablement préparé ainsi:
#      pierre@duran:~/gps$ gpsbabel -t -i gpx -f gps_log.gpx -x track,merge,start=2010010100,stop=2010123124 -o gpx -F xtract_tracks_2010.gpx
#      pierre@duran:~/gps$ ln -s xtract_tracks_2010.gpx xtract_tracks_currentyear.gpx 
#
#      (ça ^, c'était pour 2010; voici pour 2011 (et il faudra implémenter pour mettre l'année dans une variable)):
#
#      
#      
#      # pierre@autan:~$        < 2011_12_24__00_01_10 >
#      cd ~/gps
#      
#      # pierre@autan:~/gps$        < 2011_12_24__00_01_10 >
#      gpsbabel -t -i gpx -f gps_log.gpx -x track,merge,start=2011010100,stop=2011123124 -o gpx -F xtract_tracks_2011.gpx
#      
#      # pierre@autan:~/gps$        < 2011_12_24__00_01_10 >
#      ln -s xtract_tracks_2011.gpx xtract_tracks_currentyear.gpx 
#      
#
#gpscorrelate --timeadd +0:00 -g ~/gps/xtract_tracks_currentyear.gpx -O 0       -m 900 *jpg
#    Non; finalement, ça semble coincer, quand on passe par là; je fais plutôt à partir du gps_log.gpx directement:
gpscorrelate --timeadd +0:00 -g ~/gps/gps_log.gpx -O 0       -m 900 *jpg
#                                                                              15min de tolérance: 15*60=900s
#                                                                   ajuster l'offset en secondes: j'avais -264


# 2/ on remet l'heure et date au fichier depuis l'en-tête exif:
for f in *.jpg
do
  exiftool -S -d "%Y%m%d%H%M.%S" -CreateDate "${f}" \
  | awk '{ print $2 }' \
  | xargs -I % touch -m -t % "${f}"
done


