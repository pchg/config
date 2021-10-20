rebol [
	title: "conversion de fichier npadDB.pdb vers des .png"
	author: "Pierre Chevalier (pierre.marie.chevalier@wanadoo.fr)"
]

convert_npadDB_pdb_to_png: make function! [fichier] [
	if error? try [
		prin "Début de conversion de "
		print fichier
		fichier_in: to-file fichier
		fichier_out: to-file replace fichier ".jpg.pdb" ".jpg"
		if error? try [delete fichier_out] []
		monport: open/direct/binary fichier_in
		until [
			rien: copy/part monport 8
			(find rien "PNG")
			]
		i: 0
		if error? try [
			until [
				image: copy/part monport 4096
				write/binary/append fichier_out image
				;%image.jpg image
				rien: copy/part monport 8
				i: i + 1
				(rien == none)
				]
			][
			prin "Fin de conversion de "
			prin fichier
			prin " ; fin du fichier atteinte au bout de "
			prin i
			print "blocs."
			close monport
			]
		][
		print "ouverture féchier impossible"
		close monport
		]
	]


liste_fichiers: read %.
foreach fichier liste_fichiers [
	if (find fichier ".jpg.pdb") [
		print fichier
		;input
		convert_npadDB_pdb_to_png fichier
		]
]
