#!/usr/bin/rebol -wqs
rebol []
debug: false

do %~/dev/rebol/library/scripts/exif-image.r

; on se met dans le répertoire courant
; change to current directory
change-dir system/options/path

foreach f (read %.) [ ; Itération sur tous les fichiers du répertoire courant
	unless (dir? f) [   ; on ne fait quelque chose que si ce n'est pas un répertoire
		??? f
		if error? try [
			d: jpeg-datetime f
			??? d
			parse to-string f [copy name to "." copy ext to end]
			??? name
			ext: lowercase ext
			??? ext
			;rename f rejoin [pad d/year 4 "_" pad d/month 2 "_" pad d/day 2 "_" d/]
			x: replace/all to-iso-date d "-" ""
			x: replace/all x " " "_"
			x: replace/all x ":" ""
			x: trim_last_char trim_last_char x
			??? x
			rename f to-file rejoin[x ext]
			print rejoin ["renamed " f " to " to-file rejoin[x ext]]
		] [
			print rejoin["Error while trying to process " f]
		]
	]
]

