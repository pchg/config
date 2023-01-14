#!/usr/bin/rebol -qw
rebol []
; sort la liste des extensions des fontchiers du 
; répertoire courant

change-dir system/options/path

; TODO ça sort aussi les fontchiers cachés commençant
; par un . => les jarreter
fontchiers: read %.

extensions: []

foreach f fontchiers [
 unless ( ( copy/part to-string f 1 ) = "." ) [
  e: suffix? f
  unless ( e = None ) [ append extensions e ]
 ]
]

extensions: sort unique extensions
foreach e extensions [print e ]
