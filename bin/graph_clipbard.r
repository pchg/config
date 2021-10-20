#!/usr/bin/rebol -qs
rebol []
debug: false
autorefresh: true
dataset: dataset_avant: copy []

; Définitions:
; 1) modules, fonctions: 
do %~/rebol/library/scripts/q-plot.r
recup_presse_papier: does [ ;{{{ } } }
	; fonction récupérant les numerics dans le presse-papiers, et mettant ça dans le block! dataset_num
	; dataset: read %/tmp/zz 
	dataset: read clipboard://
	if (dataset = dataset_avant) [
		debug_print "RETURN PABON 15: PRESSE-PAPIERS A PAS BOUGÉ"
		return false
	]
	dataset_avant: copy dataset
	if error? try [
		debug_print "Récupération du contenu du presse-papiers:" 
		trim dataset
		dataset_num: copy []
			??? dataset      ;DEBUG
			if debug [ write %/tmp/zz dataset ]
			??? dataset_num  ;DEBUG
		foreach i to-block dataset [
			;try [ append dataset_num to-decimal to-string i ]
			either error? try [ii: to-decimal i] [
				DEBUG_PRINT "AH, YA EU ERREUR LÀ"
				debug_print rejoin [ "Skipped non-numeric value: " i ]
			] [
				DEBUG_PRINT "ON PASSE PAR ICI"
				append dataset_num ii
			]
		]
			debug_print (length? dataset_num)
			??? dataset_num
			if debug [ write %/tmp/zzz dataset_num ]
		if ( ( length? dataset_num ) <= 1 ) [ 
			debug_print "RETURN PABON 41"
			return false
		]
	] [
		debug_print "AH, YA EU ERREUR ICI"
		debug_print "Clipboard contents unplottable"
		debug_print "RETURN PABON 47"
		return false 
	]
	; Pour prendre en compte quand min = max, que ça fait une division par zéro, on rajoute une bête valeur à 1 en dernier:
	debug_print (minimum-of dataset_num) 
	debug_print (maximum-of dataset_num)
	if ((minimum-of dataset_num) = (maximum-of dataset_num)) [
		append dataset_num ((last dataset_num) + 1)
		debug_print "Attention, valeurs constantes: ajout d'une valeur + 1 à la fin, pour éviter certains désagréments."
	]
	debug_PRINT "RETURN BON 57"
	return true 
]
;}}}
; Et la fonction qui ne fonctionne plus: {{{ } } }  
;recup_presse_papier: does [ 
; ; fonction récupérant les numerics dans le presse-papiers, et mettant ça dans le block! dataset_num
; if error? try [
;  ; dataset: read %/tmp/zz
;  dataset: read clipboard://
;  trim dataset
;  dataset_num: copy []
;  ??? dataset      ;DEBUG
;  if debug [ write %/tmp/zz dataset ]
;  ??? dataset_num  ;DEBUG
;  foreach i (to-block dataset) [
;	 ;   switch (type?/word i) [
;	 ;    integer! [ append dataset_num i print "coucou"]
;	 ;    decimal! [ append dataset_num i print "coucou"]
;	 ;    money!   [ append dataset_num to-decimal i print "coucou"]
;	 ;    string!  [ prin rejoin [ "Skipped non-numeric value: " i ] ]
;	 ;    char!    [ prin rejoin [ "Skipped non-numeric value: " i ] ]
;	 ;   ]
;   unless error? try [ii: to-decimal i] [
;    append dataset_num ii
;   ]
;  ]
;  ??? (length? dataset_num)
;  ??? dataset_num
;  if debug [ write %/tmp/zzz dataset_num ]
; ] [
;  print "Clipboard contents unplottable"
;  return false
; ]
; either ( ( length? dataset_num ) > 1 ) [ return true ] [ return false ]
;]
;}}}
trace: does [ ; {{{ } } }
	; fonction traçant le graphique
	try [ 
		debug_PRINT "ON APPELLE RECUP_PRESSE_PAPIER"
		if recup_presse_papier [
			debug_PRINT "IL A RETOURNÉ DU BON"
			debug_PRINT "VOILÀ LES DONNÉES: (que la première)"
			debug_PRINT DATASET_NUM/1
			plot: none
			plot: quick-plot [ 
				300x300
				pen black
				line [ (dataset_num) ]
				;y-axis 10 border
				;x-axis 10 border
				;x-grid 10
				;y-grid 10
				;text font option-font "Formatted Text" color red up 50 over 40
			] 
		plot/offset: 0x0
		graph/pane: plot
		show graph/pane
		show window
		]
	]
]
;}}}
;
; 2) GUI:{{{
window: layout [
	; définition de l'interface
	across
	graph: box 300x300 240.240.240
	return
	btn "Refresh"                 #"r" [
		debug_PRINT "RAFRAÎCHISSEMENT MANUEL"
		trace 
	]
	return
	btn "Auto-refresh"            #"a" [
		autorefresh: not autorefresh
		??? autorefresh
		if autorefresh [
			forever [
				; dataset_avant: copy dataset
				;if (dataset != dataset_avant) [ trace ]
				trace
				wait 0.1
				unless autorefresh [exit]
			]
		]
	]
	btn "Copy graph to clipboard" #"c" [
		write clipboard:// debase to-string to-image graph
		; marche pas...
	]
	btn "Quit"                    #"q" [
		;halt  ; moins violent que quit
		quit
	]
	toggle "Debug" [
		debug: value
		?? debug
	]
]
;
;}}}
;======= fin des définitions ====

; allons-y:
view window
trace

