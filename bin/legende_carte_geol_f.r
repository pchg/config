#!/usr/bin/rebol -cs
rebol []
;red [pas réussi...]
prin "Numéro de carte géologique pour obtenir sa légende? "
num: input
; filename: rejoin ["0" num "N.pdf"] ; ne fonctionne pas pour les numéros sur 4 chiffres, comme Couflens:
filename: rejoin [(left "0000" (4 - (length? num))) num "N.pdf"]
url: to-url rejoin  ["http://ficheinfoterre.brgm.fr/Notices/" filename]
file: to-file rejoin ["~/sig/carte_geol_france_notices/" filename]
unless (exists? file) [
	tt: read/binary url
	write/binary file tt
	print ["Légende sauvée dans: " file]
	]
call rejoin ["evince " file]

