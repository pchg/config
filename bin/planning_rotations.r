#!/usr/bin/rebol
rebol []
;planning_rotations.r:
; rotations

;initialisation, paramètres: {{{ } } }
duree_voyage_jours: 3
recouvrement_jours: 2
rotations_semaines: [4 3]
date_depart: 01-10-2013 
date_fin:    15-12-2014 
etats: ["travail" "repos" "voyage"]
zapjours: 0
continue: does [throw 'continue]
; }}}

personne: make object! [ ;{{{ } } }
	nom: copy ""
	;etat: "initial"
	etat: "repos"
	etat_precedent: "repos"
	nb_jours_passes_en_l_etat: 0
	date_debut_rotations: 0
	;nb_jours_restant_en_l_etat: duree_voyage_jours
	jour_passe: does [catch [ ; {{{ } } }
		;if self/etat = "initial" [continue]
		self/nb_jours_passes_en_l_etat: self/nb_jours_passes_en_l_etat + 1
		prin rejoin [newline "-- " self/nom ": " self/etat tab "  => "]
		switch self/etat [
			"repos" [
				print "ronpchit jusqu'à nouvel ordre..."
				;either self/nb_jours_restant_en_l_etat > 0 [
				;	print rejoin ["plus que " self/nb_jours_restant_en_l_etat " jour(s) à ronquer"]
				;][
				;	print "quand faut y aller, faut y aller..."
				;	change_etat
				;]
			]
			"voyage" [
				print "navion, bateau, voiture..."
				either self/nb_jours_restant_en_l_etat > 0 [
					print rejoin ["plus que " self/nb_jours_restant_en_l_etat " jour(s) avant d'arriver"]
				][
					print "arrivé!"
					change_etat
			]	]
			"travail" [
				print "dur labeur"
				either self/nb_jours_restant_en_l_etat > 0 [
					either (self/nb_jours_restant_en_l_etat > (rotations_semaines/1 / 2)) [prin "encore "][prin "plus que "]
					print rejoin [self/nb_jours_restant_en_l_etat " au jus..."]
				][
					print "c'est la quille!!!"
					change_etat
	]	]	]	]	] ;}}}
	change_etat: does [ ; {{{ } } }
		tmp: self/etat
		switch self/etat [
			"repos"		[
				print rejoin ["J'aurai passé que " self/nb_jours_restant_en_l_etat " jours, soit " self/nb_jours_restant_en_l_etat / 7 " semaines à ronquer..."]
				self/etat: "voyage" ]
			"voyage"		[
				if/else self/etat_precedent = "travail" [self/etat: "repos"] [self/etat: "travail"]
			]
		]
		self/etat_precedent: tmp
		;if self/etat = "travail" []
		self/nb_jours_passes_en_l_etat: 0
	]; }}}
;	commence_travail: does [ ; {{{ } } }
;		self/etat_precedent: "initial"
;		self/etat: "voyage"
;			] ; }}}
	nb_jours_restant_en_l_etat: does [ ; {{{ } } }
		t: self/nb_jours_passes_en_l_etat
		switch self/etat [
			"repos"   [return ((rotations_semaines/2 * 7) - t) ]
			"voyage"  [return  (duree_voyage_jours        - t) ]
			"travail" [return ((rotations_semaines/1 * 7) - t) ]
			"initial" [tt: -1]
		]
	]; }}}
	mobilise: does[
		if self/etat = "repos" [
			change_etat
			if self/date_debut_rotations = 0 [self/date_debut_rotations: date]
		]
	]
] ;}}}

personnes: copy []
noms: copy ["Ducon" "Lajoie" "Père Vert" "Mère Noire"]
foreach n noms [append personnes make personne [nom: n]]

i: 1
date: date_depart
personnes/1/mobilise ; commence_travail	; on fait commencer le premier
num_der_personne_mobilisee: 1
decalage_entre_mobilisations_jours: (((rotations_semaines/1) * 7) - recouvrement_jours )

while [date < date_fin][
	print date
		if (date - personnes/:num_der_personne_mobilisee/date_debut_rotations) = decalage_entre_mobilisations_jours [
			; il est temps de faire commencer le suivant
			num_der_personne_mobilisee: num_der_personne_mobilisee + 1
			if (num_der_personne_mobilisee > length? personnes) [num_der_personne_mobilisee: 1]
			personnes/:num_der_personne_mobilisee/mobilise ;commence_travail			
		]
	foreach p personnes [
		p/jour_passe
	]
	print ""
	;wait 0.5									; juste pour l'affichage
	either zapjours = 0 [
		print "(touche pour passer un jour, un nombre pour zapper des jours, -1 pour breaker)"
		r: input
		either r = "" [zapjours = 0]
									[zapjours: to-integer r]
	][
		if r = "-1" [halt]
		zapjours: zapjours - 1
	]
	date: date + 1
]

