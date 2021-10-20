#!/usr/bin/rebol -qs
REBOL [;{{{ } } }
	Title:   "Gestion de mes rapports PChG"
	Date:    = 3-Nov-2013/10:31:05+1:00
	Version: 0.0.0 
	Purpose: {
	}
	History: [
	]
	License: {
This file is part of GeolLLibre software suite: FLOSS dedicated to Earth Sciences.
###########################################################################
##          ____  ___/_ ____  __   __   __   _()____   ____  _____       ##
##         / ___\/ ___// _  |/ /  / /  / /  /  _/ _ \ / __ \/ ___/       ##
##        / /___/ /_  / / | / /  / /  / /   / // /_/_/ /_/ / /_          ##
##       / /_/ / /___|  \/ / /__/ /__/ /___/ // /_/ / _, _/ /___         ##
##       \____/_____/ \___/_____/___/_____/__/_____/_/ |_/_____/         ##
##                                                                       ##
###########################################################################
  Copyright (C) 2013 Pierre Chevalier <pierrechevaliergeol@free.fr>
 
    GeolLLibre is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>
    or write to the Free Software Foundation, Inc., 51 Franklin Street, 
    Fifth Floor, Boston, MA 02110-1301, USA.
    See LICENSE file.
}
];}}}

DEBUG: true
; initialisation: ;{{{ } } }
if error? try [						; Récupération des routines (et des préférences) et connexion à la base
if error? try [						; Récupération des routines (et des préférences) et connexion à la base
do load to-file system/options/home/bin/gll_routines.r	; soit depuis ~/bin
] [
do load to-file %gll_routines.r				; ou sinon là où se trouve le script présent
]
] [
do load to-file system/options/home/geolllibre/gll_routines.r		; ou sinon dans ~/geolllibre
]
;}}}

; récupération de la liste de la table des rapports:
dbname: "pierre"
connection_db

sql_string: "SELECT * FROM pchgeol_rapports ORDER BY numrap DESC;"
run_query sql_string
reports: 			copy sql_result
reports_fields: 	copy sql_result_fields
		;== ["numrap" "date" "fini" "titre" "filename" "opid" "client" "print"]
dirty: copy [] 	; a block used as a flag to indicate whether a field is modified or not

gui: layout [ ;{{{ } } }
	backdrop white
	title "Gestion des rapports PChG"
	across
	text "SQL:" 			tab				sql: 		field 250x80 wrap 	sql_string 	[
																					sql_string: 		copy face/text
																					run_query sql_string
																					reports: 			copy sql_result
																					update_gui
																					] return
															; 75 est à la mode en ce moment (3-Nov-2013/11:03:16+1:00)
	text "numero rpt:" 	tab 		numrap: 	field 75 			""		[ dirt face ] return
	text "titre:" 		tab 		title: 		area 250x50 wrap	""		[ dirt face ] return
	text "date:"		tab 		date: 		field 75 			""		[ dirt face ] return
	text "fini:"		tab 		fini: 		check 				false 	[ dirt face ] return
	text "fichier:"		tab 		filename: 	field 250 			"" 		[ dirt face ] return
	text "operation:" 	tab 		opid: 		field 50 			"" 		[ dirt face ] return
	text "client:" 		tab 		client: 	field 100 			"" 		[ dirt face ] return
	text "imprimé:" 	tab 		print: 		check 				false 	[ dirt face ] return
	btn #"^v" "voir" [
		alert "coucou"
		cmd: rejoin ["evince " title/text]
		tt:  copy ""
		err: copy ""
		;call/wait/output/error cmd tt err
		?? cmd
	]
	btn #"^t" "test" 	[	print "test" ]
	btn #"^n" "next"  	[	save_record
							reports: next reports
							either (not (tail? reports)) [
								print (index? reports)
								update_gui				] [
								reports: back reports	] ]
	btn #"^p" "previous" [	save_record
							reports: back reports
							either (not (head? reports)) [
								print (index? reports)
								update_gui				] [
								reports: next reports	] ]
	btn #"^q" "quit" 	[	save_record
							halt		]
]

update_gui: does [
	numrap/text: 	reports/1/1
	title/text: 	reports/1/4
	date/text: 		reports/1/2
	fini/data: 		to-logic reports/1/3
	filename/text: 	reports/1/5
	opid/text: 		to-string reports/1/6
	client/text: 	reports/1/7
	print/data: 	to-logic reports/1/8
	show gui								
]

save_record: does [
	if all [ ((length? dirty) > 0) (confirm rejoin ["Fields changed: " form dirty "=> save record changes?"] ) ] [
		sql_string: "UPDATE pchgeol_rapports SET "
		foreach field dirty [
			append sql_string rejoin [field " = " :field/text]
		]
		append sql_string rejoin [" WHERE numrap = " numrap/text]
	]
]
dirt: func [ f ] [
	append dirty mold f/var
]
update_gui
view gui
do-events

unview

