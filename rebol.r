REBOL [
    Title: "User Preferences" 
    Date: 19-Jun-2012/15:13:14+2:00
	Date: 16-Jan-2020/18:51:36+1:00
]
set-net [pierrechevaliergeol@free.fr "smtp.orange.fr" "pop.free.fr" none none none] 
; NE FONCTIONNE PAS: set-net [pierre.chevalier@semofi.fr "smtp-mail.outlook.com" "pop-mail.outlook.com" none none none]

set-user-name "Pierre Chevalier"

; de jolies couleurs pour view:{{{
if (not none? system/view) [
    system/view/screen-face/options: none
	svv/vid-face/color: white
] 
;}}}

; a simple word to include gll_routines:{{{
gll_routines: does load to-file system/options/home/geolllibre/gll_routines.r		; ou sinon dans ~/geolllibre
; encore plus simple: j'inclus d'emblée gll_routines.r, et voilà:
gll_routines
;print {===---  GeolLLibre routines loaded: gll_routines.r  ---===}
;print newline
;}}}

; inclusion of useful libraries:{{{

;do %~/dev/rebol/library/scripts/base-convert.r


;}}}

; des fonctions un peu en vrac, utilitaires plus ou moins inutiles: {{{

; compte à rebours pour les anglicismes:{{{
brexit_compte_a_rebours: does [
	jours_restants: 31/01/2020 - now
	case [
		jours_restants > 0 [sortie: rejoin ["Il ne reste plus que " jours_restants " jours avant le brexit."]]
		jours_restants = 0 [sortie: "Ah! C'est aujourd'hui que le brexite: désormais, plus d'anglicismes!"]
		jours_restants < 0 [sortie: rejoin ["Cela fait déjà " jours_restants " que le brexit a eu lieu: les anglicismes appartiennent désormais au passé, les contrevenants seront sévèrement punis et ridiculisés en place publique. Non mais."]]
	]
	print sortie
]
;Il ne reste plus que 15 jours avant le brexit.
;}}}

; pour sauver l'historique de la console, et le restaurer:{{{
save-history: does [
	tt: copy system/console/history
	ttt: copy []
	foreach t tt [ unless ( t = "q" ) [ append ttt t ] ]
    save %~/.rebol_conshist.r ttt ]
load-history: does [
    system/console/history: load %~/.rebol_conshist.r ]

my-quit: :quit
q: func [
    {Stops evaluation, save the console history and exits the interpreter.}
    /return value [integer!]
] [
	save-history
    either return [
        my-quit/return value
    ] [
        my-quit
]   ]
do load-history
;}}}

travail_base_de_donnees: func ["Bascule entre une base de travail et une autre: postgeol et par" db_shortname] [; {{{
	db_shortname: to-string db_shortname
	?? db_shortname
	; commun à toutes les bases:
	dbhost:      "latitude"
	dbuser:      "pierre"
	postgeol:    "postgeol"
	dbport:      5432
	switch/default db_shortname [
		"postgeol" [
			dbname:      "postgeol"
		]
		"par" [
			dbhost:      "pellehovh"
			dbname:      "par_02"
		]
	]
	[
		print "Pour l'instant, seuls postgeol et par sont acceptés."
	]
	?? dbhost
	?? dbuser
	?? postgeol
	?? dbport
	connection_db
]
;}}}

; pour faire calculette:{{{
context [
    digit: charset "0123456789" 
    not-digit: complement digit 
    load-calc: func [str [string!] /local new pos s e] [
        new: make block! 1 
        unless parse str [
            pos: any [
                s: [some digit | some not-digit] e: 
                (append new load copy/part s e)
        ]   ]   [
            print ["*** Syntax Error at:" pos] ] 
        new ] 
    set 'calc does [
        forever [
            str: ask "calc>> " 
            print ["==" do load-calc str]
]   ]   ] 
;}}}

; conversions de sousous:{{{

rate_sdg_per_euro:   49.95 ;SDG/EUR
rate_sdg_per_dollar: 45.09 ;SDG/USD
rate_euro_per_dollar: 0.9  ;EUR/USD

sdg2dollar: func [val] [ return val / rate_sdg_per_dollar ]
dollar2sdg: func [val] [ return val * rate_sdg_per_dollar ]
sdg2euro:  func [val] [ return val / rate_sdg_per_dollar * rate_euro_per_dollar ]
euro2sdg:   func [val] [ return val * rate_sdg_per_dollar / rate_euro_per_dollar]

;}}}

; pour remettre l'écran à zéro:{{{
cls: does [prin "^(1B)[J"]
;}}}

; un raccourci pour charger anamonitor:{{{
anamonitor: does [do %~/rebol/tools/anamonitor300.r]
;}}}

; define a COPY function to copy files, fully (not just the file's contents):{{{
copy-file: function [{Copy one file to another} file_in [file!] file_out [file!]] [cmd tt err] [
    switch/default system/version/4 [
        2 [;OSX
            cmd: "cp"      ]
        3 [;Windows
            cmd: "copy"    ]
        4 [;Linux
            cmd: "cp"      ]
        7 [;FreeBSD
            cmd: "cp"      ]
        8 [;NetBSD
            cmd: "cp"      ]
        9 [;OpenBSD
            cmd: "cp"      ]
        10 [;Solaris
            cmd: "cp"      ]
    ] [;Can't be determined
        cmd: "cp"          ]
    append cmd rejoin [" " to-string file_in " " to-string file_out]
    tt:  copy ""
    err: copy ""
    print cmd
    call/wait/output/error cmd tt err
    return tt
]
;}}}

; une fonction pour convertir vite fait des FCFA en euros:{{{
cfa2euros: func [val_cfa] [ return (val_cfa / 100 / 6.55957) ]
;}}}

; fonction crypt, repompée depuis: http://www.rebol.com/how-to/encrypt.html{{{
crypt: func [
    "Encrypts or decrypts data and returns the result."
    data [any-string!] "Data to encrypt or decrypt"
    akey [binary!] "The encryption key"
    /decrypt "Decrypt the data"
    /binary "Produce binary decryption result."
    /local port
] [
    port: open [
        scheme: 'crypt
        direction: pick [encrypt decrypt] not decrypt
        key: akey
        padding: true
    ]
    insert port data
    update port
    data: copy port
    close port
    if all [decrypt not binary] [data: to-string data]
    data
]
;}}}

; rot-13: {{{

;https://rosettacode.org/wiki/Rot-13#REBOL 
;"Using parse:"

; NB: pour Red: il faut faire:
; money!: make typeset! number!

clamp: func [
 "Contain a value within two enclosing values. Wraps if necessary."
 x v y
][
 x: to-integer x  v: to-integer v  y: to-integer y
 case [v < x [y - v] v > y [v - y + x - 1] true v]
]
 
; I'm using REBOL's 'parse' word here. I set up character sets for
; upper and lower-case letters, then let parse walk across the
; text. It looks for matches to upper-case letters, then lower-case,
; then skips to the next one if it can't find either. If a matching
; character is found, it's mathematically incremented by 13 and
; clamped to the appropriate character range. parse changes the
; character in place in the string, hence this is a destructive
; operation.
 
rot-13: func [
 "Encrypt or decrypt rot-13 with parse."
 text [string!] "Text to en/decrypt. Note: Destructive!"
] [
 u: charset [#"A" - #"Z"]
 l: charset [#"a" - #"z"]
 
 parse text [some [
   i:                                          ; Current position.
   u (i/1: to-char clamp #"A" i/1 + 13 #"Z") | ; Upper case.
   l (i/1: to-char clamp #"a" i/1 + 13 #"z") | ; Lower case.
   skip]]                                      ; Ignore others.
 text
]
; }}}

; Inutilités, poubelle:{{{
; les sangliers: {{{
sangliers_chansons_email: does [
	;destinataires: [pierrechevaliergeol@free.fr] ; POUR TESTS
	;destinataires: [pierrechevaliergeol@free.fr lolitani@orange.fr christophe.hourteillan@neuf.fr vince256@voila.fr]
	destinataires: [pierrechevaliergeol@free.fr lolitani@orange.fr christophe.hourteillan@neuf.fr jimsourbes@gmail.com]
	sangliers: run_query "SELECT DISTINCT whosuggests FROM songs ORDER BY 1;"
	output: copy {}
	foreach s sangliers [
	s: first s
	append output rejoin [newline newline s ":" newline]
	artistes: run_query rejoin [{SELECT DISTINCT artist FROM songs WHERE whosuggests = '} s "' ORDER BY 1;"]
	foreach a artistes [
		a: to-string a
		append output rejoin [newline " " a ":" newline]
		sql: rejoin [{SELECT title, url, mp3, au_point FROM songs WHERE whosuggests = '} s "' AND artist = '" a "' ORDER BY 1;"]
		chansons: run_query sql
		foreach c chansons [
			append output "  "
			if (reduce (c/4)) = 1 [ append output "==> " ]
			append output rejoin [ c/1 newline "     youtube:" tab c/2 newline "         mp3:" tab c/3 ]
			append output newline
] ] ] print output
prin "Message?"
msg: input
if confirm "Envoi de l'émail?" [send/only/show/subject destinataires rejoin [
"Coucou, " newline "Voilà la liste de morceaux, à jour de " now ", avec les morceaux au point marqués par un ==> :" newline newline output newline msg newline
] "Tcho Sangliers"
]
]
;}}}

; les amphorés: {{{
amphores_chansons_email: does [
dbname_avant: dbname
dbname: "pierre"
connection_db
;destinataires: [pierrechevaliergeol@free.fr lolitani@orange.fr pl_toulouse@yahoo.fr ben.biut@hotmail.fr]
;destinataires: [pierrechevaliergeol@free.fr lolitani67@gmail.com christophe.hourteillan@neuf.fr vince256@voila.fr]
destinataires: [pierrechevaliergeol@free.fr] ; POUR TESTS
sangliers: ["Philou"] ;run_query "SELECT DISTINCT whosuggests FROM songs ORDER BY 1;"
output: copy {}
foreach s sangliers [
	s: first s
	append output rejoin [newline newline s ":" newline]
	artistes: run_query rejoin ["SELECT DISTINCT artist FROM songs WHERE whosuggests = '" s "' ORDER BY 1;"]
	foreach a artistes [
		a: to-string a
		append output rejoin [newline " " a ":" newline]
		sql: rejoin ["SELECT title, url, mp3, au_point FROM songs WHERE whosuggests = '" s "' AND artist = '" a "' ORDER BY 1;"]
		chansons: run_query sql
		foreach c chansons [
			append output "  "
			if (reduce (c/4)) = 1 [ append output "==> " ]
			append output rejoin [ c/1 newline "     youtube:" tab c/2 newline "         mp3:" tab c/3 ]
			append output newline
] ] ] print output
prin "Message?"
msg: input
if confirm "Envoi de l'émail?" [send/only/show/subject destinataires rejoin [
"Coucou, " newline "Voilà la liste de morceaux, à jour de " now ", avec les morceaux au point marqués par un ==> :" newline newline output newline msg newline
] "Tcho Sangliers"
]
dbname: dbname_avant
connection_db
]

;}}}

Tessai_restante: does [
print (1/4/2018 + (6 * 30)) - now
]

;}}}

;}}}

; singeries:{{{

mp: does [do reverse decompress #{
789C358CC10EC2300C43EFFD8AA81247D87D7C01377E2134D188B6B5254D91DA
AF5F1170B2E567DBE51D3499103B3F375E3D30C9735A0B42538CF238270315DC
02665EA214DE4E3F3211B2FEBDE5A681E9AB308A6AE5339DC7BFBFE4BD442454
5165330C558DBB614F05A4BE2A777ECB021411AEF1369201EBDD838D9BEC0EEA
713C25A3000000
}]
;}}}

