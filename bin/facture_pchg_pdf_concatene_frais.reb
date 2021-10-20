#!/usr/bin/rebol -qs
rebol []

pad: func [ ;{{{ } } }
 "Pads a value with leading zeroes or a specified fill character."
  val [string! number!] n [integer!]
  /with c [char!] "Optional Fill Character"
][
  head insert/dup val: form val any [all [with c] #"0"] n - length? val] ;}}}

numero_facture:  first  system/options/args
files_pdf_frais: at     system/options/args 2
chemin_factures: "~/pchgeol/admin/factures/emises/"

;numero_facture: 67
;file_pdf_frais: to-file {~/ngosso/admin/scan_factures_frais.pdf}
prin "# Numéro de facture: " print numero_facture
file_pdf_facture: rejoin [{facture_pchg_} pad numero_facture 3 {.pdf}]
file_ods_facture: rejoin [{facture_pchg_} pad numero_facture 3 {.ods}]



cmd: rejoin [{pdftk A=} chemin_factures file_pdf_facture { }]

ltr: #"A"
foreach file_pdf_frais files_pdf_frais [
	ltr: ltr + 1
	append cmd rejoin [ltr {=} file_pdf_frais { }]
]

append cmd {cat A }
for i #"B" ltr 1 [
	append cmd rejoin [to-string i " "]
]
append cmd rejoin [{output } chemin_factures file_pdf_facture {_ &&}
newline
{evince } chemin_factures file_pdf_facture {_ &&}
newline
{mv } chemin_factures file_pdf_facture { } chemin_factures file_pdf_facture {.non -f &&}
newline
{mv } chemin_factures file_pdf_facture {_ } chemin_factures file_pdf_facture { -f &&}
newline
{mv } chemin_factures file_ods_facture { } chemin_factures
]

print cmd

if confirm rejoin [{Exécution de la commande } cmd] [
		tt:  copy ""
		err: copy ""
		call/wait/output/error cmd tt err
]
