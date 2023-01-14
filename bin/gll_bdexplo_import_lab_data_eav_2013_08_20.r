#!/usr/bin/rebol
rebol [ ;{{{} } }
	Title:   "Import assay data from lab into database"
	Name:    gll_bdexplo_import_lab_data_eav.r
	Version: 1.1.0
	Date:    "20-Aug-2013/13:47:08+2:00"
	Author:  "Pierre Chevalier"
	Licence: {
		  Copyright 2013 Pierre Chevalier <pierrechevaliergeol@free.fr>
		  
		  This program is free software; you can redistribute it and/or modify
		  it under the terms of the GNU General Public License as published by
		  the Free Software Foundation; either version 2 of the License, or
		  (at your option) any later version.
		  
		  This program is distributed in the hope that it will be useful,
		  but WITHOUT ANY WARRANTY; without even the implied warranty of
		  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		  GNU General Public License for more details.
		  
		  You should have received a copy of the GNU General Public License
		  along with this program; if not, write to the Free Software
		  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
		  MA 02110-1301, USA.
		}
	History: [
	1.0.0 [5-Aug-2013/17:53:46 {
		Je fais un script traitant d'un seul coup les r�sultats 
		analytiques livr�s en EAV par Bureau Veritas depuis un 
		syst�me LIMS.
		Je fais �a en pseudo-code, converti en rebol.}]
	1.0.1 [15-Aug-2013/09:34:48 {
		print "JE NE MARCHE PAS!"	laiss� ce script ainsi sur duran � la 
		quit				SMI, de mani�re � ce qu'il ne tourne PAS
						tant que �a ne marche pas correctement.
						Il faudra �diter, logg� en tant que smiexplo 
						sur duran, le fichier
						/usr/bin/gll_bdexplo_import_lab_data_eav.r
						et y coller le contenu de ce fichier.}]
	1.1.0 [15-Aug-2013/19:14:48 {
		Traitement de donn�es scind�es en deux fichiers .csv: usage:
		gll_bdexplo_import_lab_data_eav.r abj13000032_header.csv abj13000032_dataqc.csv
		R�ussite, � Cocody Riviera Deux dans embouteillages in�narrables... 
		Tout a march� parfaitement; en revanche, �a a �t� _tr�s_ long: TODO voir pourquoi}]
	1.1.0 [20-Aug-2013/19:13:50+2:00 {
		Modification pour le format fourni par Veritas avec en-t�te et valeurs dans le m�me fichier}]
	]
	] ;}}}
; initialisation: {{{ } } }
; R�cup�ration des routines (et des pr�f�rences):
change-dir system/options/path				; on se met dans le r�pertoire courant (...)

; on a 4 choix:
catch [
if error? try [gll_routines: load to-file system/options/home/bin/gll_routines.r
		throw "gll_routines loaded from ~/bin/"					]
	[print "-"]
if error? try [gll_routines: load to-file %usr/bin/gll_routines.r	
		throw "gll_routines loaded from /usr/bin/"				]
	[print "-"]
if error? try [gll_routines: load to-file rejoin [ system/options/path "gll_routines.r"]	
		throw "gll_routines loaded from current directory"			]
if error? try [gll_routines:
	; TODO mettre le contenu de gll_routines.r ici, en faisant en sorte que �a marche
;; En d�sespoir de cause, si rien de tout cela n'est trouv�, on inclut une 
;; version fixe, "compil�e" ainsi:
;comment [
;change-dir system/options/path
;write %gll_routines_compress compress to-binary mold read to-file system/options/home/bin/gll_routines.r
;:r gll_routines_compress
;
;write/append %bin/gll_bdexplo_import_lab_data_eav.r read to-file system/options/home/bin/gll_routines.r
;
;]
		throw "gll_routines loaded from current script copy"			]
	]

if error? try [do gll_routines] [print "Problem, no preferences found, cannot continue." quit]

; si passw n'est pas d�fini, on le demande:
if any [(error? try [(none? passw)]	)
	(passw = none			)
	(passw = ""			)] [
passw: ask/hide "password: "		]

;on r�cup�re le code de gll_bdexplo_new_datasource.r
if error? try [load to-file system/options/home/bin/gll_bdexplo_new_datasource.r	] [
if error? try [do load to-file %usr/bin/gll_bdexplo_new_datasource.r			] [
if error? try [do load to-file %gll_bdexplo_new_datasource.r				] [
;; En d�sespoir de cause, on inclut le code "mort" ici:
;; TODO

]]]

; connection � la base
connection_db

; si pas de journal des instructions SQL, on en cr�e un vide
if error? try [ type? journal_sql ] [journal_sql: [] ]

; un peu d'espace pour la grande instruction SQL:
sql_string: make string! 10000
; }}}

; DEBUG: �VITER V    ####################################################
;if system/options/args = none [print "Pabon" 	quit]
;if length? system/options/args < 2 [print rejoin ["Pabon: ifo utiliser avec deux fichiers; par exemple: " newline "gll_bdexplo_import_lab_data_eav.r abj13000032_header.csv abj13000032_dataqc.csv"]
;					quit]
if any [(length? system/options/args <> 1) (system/options/args = none)] [print rejoin ["Error, one single file must be provided as arguments." newline "Example:" newline "gll_bdexplo_import_lab_data_eav.r ABJ13000003.CSV" quit]

;file_in_header: to-file pick system/options/args 1
;file_in_dataqc: to-file pick system/options/args 2

file_in: to-file pick system/options/args 1

comment [ ;DEBUG: jeu de test
	;file_in: %~/smi/transferts/from/sidiki_fofana/2013_08_11/tt/abj13000028.csv
	;file_in: %~/smi/transferts/from/sidiki_fofana/2013_08_14/abj13000003_dataqc.csv
	;file_in: %~/smi/transferts/from/sidiki_fofana/2013_08_14/abj13000003_dataqc.csv
; DEBUG              ####################################################

 ;{{{DEBUG: FAIRE TOURNER } } } 
	;change-dir %~/smi/transferts/from/sidiki_fofana/2013_08_15/tt
	;arg1: "abj13000032_header.csv"
	;arg2: "abj13000032_dataqc.csv"
	;file_in_header: to-file arg1
	;file_in_dataqc: to-file arg2
	change-dir  %~/smi/transferts/from/sidiki_fofana/2013_08_20/tt/
	arg1: "ABJ13000003.CSV"
	file_in: to-file arg1

;}}}
	]
; test si les fichiers existent:
;if not chk_file_exists file_in_header [print "Pabon"	quit]
;if not chk_file_exists file_in_dataqc [print "Pabon"	quit]
if not chk_file_exists file_in [print rejoin "Problem, unable to open file " to-string file_in " ; cannot continue."	quit]

; commencer une transaction:
insert db "BEGIN TRANSACTION;"

;##################################

; g�n�rer un datasource_id:
get_new_datasource_id
either (test_datasource_available new_datasource_id) [
	print rejoin ["ok, proposed datasource_id " new_datasource_id " free in database" ]
	generate_sql_string_update new_datasource_id file_in
	; NB: sql_string_update contient maintenant le SQL � jouer � la fin
	] [
	print rejoin ["problem, proposed datasource_id " new_datasource_id " already referenced in database: ^/" res ]
	quit ]
; sql_string contient l'ensemble des instructions � jouer, et on peut oublier sql_string_update:
sql_string: rejoin ["" newline sql_string_update]

; lecture partie m�tadonn�es (en-t�te fichier) et reste des donn�es, dans 2 block!s, header et data: {{{ } } } 

lines: read/lines file_in
header: copy []
data:   copy []
flag_header: true
foreach line lines [
	either flag_header [
		append/only header line
		if any [
			(line = newline) 
			(line = none) 
			(line = "") 
			;((copy/part line 6) = "Jobno,")
			] 
			[flag_header: false]
		] [
		append/only data line
		]
	]
; header contient maintenant les lignes d'en-t�te, et
; data   contient maintenant les lignes de donn�es.

; conversion du contenu de header en variables:
foreach l header [
	t: parse/all l ","
	do rejoin [(lowercase to-string t/1) {"} t/2 {"}]
	]

; si tout va bien, les variables suivantes sont d�finies:/*{{{*/ } } }
labname 
client
validated
job_number
number_of_samples
project
shipment_id
p_o_number
received

; exemple pour le fichier ABJ13000003.CSV:
;
;>> labname 
;== "ACME ANALYTICAL LABORATORIES LTD."
;>> client
;== "Societe Des Mines D'Ity (SMI)"
;>> validated
;== "31-May-13"
;>> job_number
;== "ABJ13000003"
;>> number_of_samples
;== "6"
;>> project
;== "None Given"
;>> shipment_id
;== "BV130425SMI"
;>> p_o_number
;== "2013 04 25"
;>> received
;== "29-May-13"

; /*}}}*/

; contr�le de l'en-t�te: {{{ } } }
; non: {{{  } } }
;>> i: 1                                                      
;== 1
;>> foreach x header_h [print rejoin [ {header_h/} i { = "} x {"}] i: i + 1]
;header_h/1 = "Labname"
;header_h/2 = "Client"
;header_h/3 = "Validated"
;header_h/4 = "Job_number"
;header_h/5 = "Number_of_samples"
;header_h/6 = "Project"
;header_h/7 = "Shipment_id"
;header_h/8 = "P_O_number"
;header_h/9 = "Received"
; }}}
either all [
not none? labname 
not none? client
not none? validated
not none? job_number
not none? number_of_samples
not none? project
not none? shipment_id
not none? p_o_number
not none? received
] [
; print " tout baigne "
] [ print rejoin ["Error: data header from " to-string file_in " differs from expected format: " newline ]
	quit]
;}}}

;obsol�te: {{{ } } }
; il n'y a qu'une ligne o� lire les valeurs:
;header_val: parse/all second data ","
;
; on construit les variables:
;repeat n (length? header_h) [
;	do rejoin [lowercase header_h/:n {: "} header_val/:n {"}]
;	]
;
;On a maintenant les variables suivantes d�finies:
;>> foreach c header_h [print lowercase c]
;labname
;client
;validated
;job_number
;number_of_samples
;project
;shipment_id
;p_o_number
;received
;}}}
;/*{{{*/Brouillons:
	;prin header_h/:n
	;prin tab
	;print header_h/(:n + (length? header_h))
;
;
;foreach f header_h [
;toutou: append header_h header_val
;foreach x toutou [
;print x
;print toutou/((length? header_h) - 1)
;input 
;]
;/*}}}*/
;}}}

; lecture des analyses: {{{ } } } 
; d�j� faite, dans data
data_h: parse/all first data ","
; contr�le de l'en-t�te: {{{ } } }

;>> i: 1                                                      
;== 1
;>> foreach x data_h [print rejoin [ {data_h/} i { = "} x {"}] i: i + 1]
;data_h/1 = "Jobno"
;data_h/2 = "Orderno"
;data_h/3 = "Sampletype"
;data_h/4 = "Sampleid"
;data_h/5 = "Scheme"
;data_h/6 = "Analyte"
;data_h/7 = "Value"
;data_h/8 = "Unit"
;data_h/9 = "DetLim"
;data_h/10 = "UpLim"
either all [
data_h/1 = "Jobno"
data_h/2 = "Orderno"
data_h/3 = "Sampletype"
data_h/4 = "Sampleid"
data_h/5 = "Scheme"
data_h/6 = "Analyte"
data_h/7 = "Value"
data_h/8 = "Unit"
data_h/9 = "DetLim"
data_h/10 = "UpLim"
] [
; print " tout baigne "
] [ print rejoin ["Error: data header from " to-string file_in " differs from expected format: " newline ]
	quit]
;}}}
;}}}

s: "', '" ; s�paration de 2 textes en SQL (raccourci)

; importer les donn�es dans les tables:
;public.lab_ana_results: {{{ } } }
; non {{{ } } }
; champs du ficher %~/smi/transferts/from/sidiki_fofana/2013_08_14/abj13000003_dataqc.csv
;  # pierre@autan: ~/smi/transferts/from/sidiki_fofana/2013_08_14        < 2013_08_14__23_23_05 >
;head ~/smi/transferts/from/sidiki_fofana/2013_08_14/abj13000003_dataqc.csv
;Jobno,Orderno,Sampletype,Sampleid,Scheme,Analyte,Value,Unit,DetLim,UpLim
;ABJ13000003,2013 04 25,Rock Pulp,0001V,1D,Mo, 1,PPM,1,2000
;ABJ13000003,2013 04 25,Rock Pulp,0001V,1D,Cu, 15,PPM,1,10000
;ABJ13000003,2013 04 25,Rock Pulp,0001V,1D,Pb, 6,PPM,3,10000
;ABJ13000003,2013 04 25,Rock Pulp,0001V,1D,Zn, 36,PPM,1,10000
;ABJ13000003,2013 04 25,Rock Pulp,0001V,1D,Ag,<0.3,PPM,0.3,100
;ABJ13000003,2013 04 25,Rock Pulp,0001V,1D,Ni, 4,PPM,1,10000
;ABJ13000003,2013 04 25,Rock Pulp,0001V,1D,Co, 2,PPM,1,2000
;ABJ13000003,2013 04 25,Rock Pulp,0001V,1D,Mn, 92,PPM,2,10000
;ABJ13000003,2013 04 25,Rock Pulp,0001V,1D,Fe, 0.80,%,0.01,40

; les champs du fichier de donn�es:
	;Jobno,Orderno,Sampletype,Sampleid,Scheme,Analyte,Value,Unit,DetLim,UpLim
; les champs de la table:
	;labname, jobno, orderno, sample_id, scheme, analyte, value, db_update_timestamp, value_num, opid, batch_id, sampletype, unit, datasource, numauto, sample_id_lab, valid, detlim, uplim
; }}}
;>> labname 
;== "ACME ANALYTICAL LABORATORIES LTD."
; => attention, champ trop court dans la table public.lab_ana_results:
;  	labname             | character varying(10)
; => on tronque:		TODO am�liorer
;>> first parse labname " "
;== "ACME"
labo: first parse labname " "

sql_string: rejoin [sql_string newline "INSERT INTO public.lab_ana_results (opid,      labname,   jobno,  orderno, sample_id, scheme, analyte, value, sampletype, unit,         datasource, detlim, uplim) VALUES " newline]
foreach line next data [
	b: make block! 100
	append b parse/all line ","
	sql_string:              rejoin [sql_string "("  opid ", '" labo     s  b/1 s     b/2 s      b/4 s   b/5 s    b/6 s  b/7 s       b/3 s b/8 "', " new_datasource_id ", "   b/9 ", " b/10 ")," newline]
	                        ;rejoin [sql_string "("  opid ", '" labname  s  h/1 s     h/2 s      h/4 s   h/5 s    h/6 s  h/7 "', "   h/3 s h/8 s new_datasource_id s   h/9 s h/10 ")," newline]
	]
sql_string: rejoin [copy/part sql_string ((length? sql_string) - 2) ";"]
;}}}

;public.lex_datasource: fait, cf.supra
prin "New datasource generated: "
print new_datasource_id

;public.lab_ana_batches_reception/*{{{*/ } } }

;labname
;client
;validated
;job_number
;number_of_samples
;project
;shipment_id
;p_o_number
;received

client: replace client "'" "\'" ; {Societe Des Mines D'Ity (SMI)}   >:-<
a: to-date validated
validated: rejoin [a/year "-" a/month "-" a/day]
a: to-date received
received:  rejoin [a/year "-" a/month "-" a/day]

tt: {INSERT INTO public.lab_ana_batches_reception 
    (opid,            jobno,             datasource,     labname , client , validated , job_number ,     number_of_samples ,     project , shipment_id , p_o_number , received ) VALUES }
tt: rejoin [tt newline "( "  opid ", '" job_number "', " new_datasource_id ", '" labname s client s validated s job_number "', " number_of_samples ", '" project s shipment_id s p_o_number s received "');"]

sql_string: rejoin [sql_string newline tt]


;/*}}}*/

;public.dh_sampling_grades


;write %rtr rejoin ["BEGIN TRANSACTION;" newline sql_string]
;write %test.sql sql_string
; =>	(�a marche:) {{{ } } }
;  # pierre@autan: ~/smi/transferts/from/sidiki_fofana/2013_08_15/tt        < 2013_08_15__18_16_50 >
;psql -h autan -d bdexplo -f toto.csv
;ERROR: ld.so: object '/lib/libreadline.so.5' from LD_PRELOAD cannot be preloaded: ignored.
;ERROR: ld.so: object '/lib/libreadline.so.5' from LD_PRELOAD cannot be preloaded: ignored.
;ERROR: ld.so: object '/lib/libreadline.so.5' from LD_PRELOAD cannot be preloaded: ignored.
;ERROR: ld.so: object '/lib/libreadline.so.5' from LD_PRELOAD cannot be preloaded: ignored.
;ERROR: ld.so: object '/lib/libreadline.so.5' from LD_PRELOAD cannot be preloaded: ignored.
;SET
;BEGIN
;INSERT 0 1
;INSERT 0 4
;INSERT 0 1
;COMMIT
;}}}
; => �a remarche: {{{ } } }
  # pierre@autan: ~/smi/transferts/from/sidiki_fofana/2013_08_20/tt        < 2013_08_20__19_03_00 >
psql -h autan -d bdexplo -f test.sql 
SET
BEGIN
INSERT 0 1
INSERT 0 297
INSERT 0 1

; }}}

insert db sql_string
insert db "COMMIT;"
