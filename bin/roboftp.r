#!/usr/bin/rebol -qs
REBOL [
	title: "client FTP automatisé"
	author: "Olivier Auverlot"
	version: 1.0
	purpose: {
	RobotFTP permet l'exécution de commandes FTP
	afin d'automatiser l'envoi ou la réception 
	de fontchiers.
	
	Usage:
	robotftp script-de-commandes
	}
    ]

erreur: func [
	"Affiche un message d'horreur" 
	msg [ string! ] "Description du problème" 
	/fatale "L'horreur implique l'arrêt du programme, arrêt définitif, sans retour dans le temps possible, ce programme est mort à la seconde où vous lisez tout ça..."
	] [
	print msg
	if fatale [quit]
	]


;comment {[
;Je teste la fonction tout juste créée:
;>> error! error? erreur
;help erreur 
;USAGE:
;    ERREUR msg /fatale 
;
;DESCRIPTION:
;     Affiche un message d'horreur
;     ERREUR is a function value.
;
;ARGUMENTS:
;     msg -- Description du problème (Type: string)
;
;REFINEMENTS:
;     /fatale -- L'horreur implique l'arrêt du programme, arrêt définitif, sans retour dans le temps possible, ce programme est mort à la seconde où vous lisez tout ça...
;
;>> erreur "au revoir"
;au revoir
;== none
;>> erreur/fatale "adishatz" 
;adishatz
;
;  # pierre@autan: ~$        < 2013_02_15__11_26_20 >
;
;]}


if error? try [
	commandes: do load to-file first system/options/args
	] [
	erreur/fatale "Impossible de charger le script"
	]

; si on débogue, faire ça, à la place du try précédent:
;commandes: do load %script_commandes_pour_roboftp.r
;commandes: do load %script_commandes_pour_roboftp_maj_cv_sur_free.r




if view? [
	stp: 1 / ((length? commandes/script) / 2)
	affiche-progression: does [
		view/new center-face boite-ftp: layout [
			title "RobotFTP"
			progression: progress
			]
		]
]


ftpurl: copy "ftp://"
if not none? get in commandes 'user [
if     none? get in commandes 'password [
	print join ["host: " commandes/host]
	print join ["user: " commandes/user]
	password: ask "password? "
]
ftpurl: join ftpurl [commandes/user ":" commandes/password "@"]
]
ftpurl: join ftpurl commandes/host

if not none? get in commandes 'passive [
if commandes/passive = true [system/schemes/ftp/passive: true]
]

curdir: copy %/

if view? [affiche-progression]

rules: [
	any [
		'quit                   (quit) |
		'debug  set arg string! (print arg) |
		'lcd    set arg file!   (exec-cmd [change-dir arg]) |
		'get    set arg file!   (exec-cmd [write arg (read/binary make-ftpurl arg)]) |
		'put    set arg file!   (exec-cmd [write/binary (make-ftpurl arg) read/binary arg]) |
		'cd     set arg file!   (
			either arg = %/ [
				curdir: copy %/
				][
				append curdir reduce [arg "/"]
				]
			) |
		'mkdir  set arg file!   (exec-cmd [make-dir make-ftpurl/directory arg]) |
		'delete set arg file!   (exec-cmd [delete make-ftpurl arg]) |
		'rmdir  set arg file!   (exec-cmd [delete make-ftpurl/directory arg]) |
		'mput   set arg file! (
			exec-cmd [
				foreach fichier read %. [
					if (suffix? fichier) = arg [
						write/binary (make-ftpurl fichier) read/binary fichier
						]
					]
				]
			) |
		'mget   set arg file! (
			exec-cmd [
				fichiers: read make-ftpurl ""
				forall fichiers [
					fichier: first fichiers
					if (suffix? fichier) = arg [
						write/binary fichier read/binary (make-ftpurl fichier)
						]
					]
				]
			)
	]
]

exec-cmd: func [
	cmd [block!] "Instructions Rebol"
	/local err
	] [print cmd
	if error? (try [do cmd
		if view? [
			progression/data: progression/data + stp
			show progression
			]
		]) [print mold disarm err]]

make-ftpurl: func [ "Construit l'URL pour les commandes FTP" arg [file! string!] "Argument passé par le dialecte" /directory "L'URL concerne un répertoire"] [
clean-path curdir
either not directory [
	to-url join ftpurl [curdir arg]
	] [
	to-url join ftpurl [curdir arg "/"]
	]
]


parse commandes/script rules

if view? [
	request/ok "Opérations terminées"
	unview boite-ftp
	]

