#!/usr/bin/rebol -qs
rebol []
; Appel à https://adresse.data.gouv.fr/api
print "Récupération d'adresse géographique et envoi par courriel aussi sec."
prin "adresse à rechercher: "
adr: input
replace/all adr " " "+"
url: rejoin [ {curl "https://api-adresse.data.gouv.fr/search/?q=} adr {"} ]
labas: call_wait_output_error url
prin "courriel où envoyer le résultat: "
courriel: to-email input
send/subject courriel labas "Adresse récupérée par api-adresse.data.gouv.fr"
write/append %tmp_adresse.geojson rejoin [labas newline]
print "Le fichier tmp_adresse.geojson contient le résultat de cette requête, ajouté à la fin."

