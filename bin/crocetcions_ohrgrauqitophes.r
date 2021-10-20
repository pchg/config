#!/usr/bin/rebol -wqs
rebol []
;"""Un programme mettant en évidence l'inutilité de l'orthographe pour la compréhension d'un texte"""
;"""Un proarmgme mtatent en éeicnvde ltii'ltniué de lghportr'aohe pour la crohepénosimn du'n txete """

; d'abord écrit en python, traduit en rebol

random/seed now/time/precise

ligne: does [ loop 80 [prin "_"] print "" ]

; début du programme
cmd_line: system/script/args
; si rien n'est spécifié en argument, on met une phrase lambda; 
; sinon, on traite tout le reste de la ligne de commande:
either (cmd_line) [
	text: cmd_line
	][
	text: "Arrêtez de m'emmerder avec les corrections orthographiques de merde"
	]

ligne
print "               .oO== texte original:   ==Oo."
print text
ligne
print ""
ligne
print "               .oO== txete oirignal:   ==Oo."

mots: parse text " "
textout: copy ""
foreach mot mots [
	either ((length? mot) > 3) [	; mot de plus de 3 lettres: interversion aléatoire
		motout: copy ""				; mot en sortie, qui sera invretrtvi
		append motout first mot
		append motout (random (copy/part at mot 2 ((length? mot) - 2) ) )
		append motout last mot
		append textout join motout " "
	][
		append textout join mot " "
	]
]

print textout
ligne

