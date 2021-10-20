#!/usr/bin/rebol -qs
rebol []

;chercher:      first  system/options/args
;remplacer_par: at     system/options/args 2

sql_string: copy ""
until [
print "Chaîne à rechercher (chaîne vide pour arrêter): "
chercher: input
print "Remplacer par: "
remplacer_par: input
continuer: ((length? chercher) > 0)
tt: rejoin [ "UPDATE public.field_observations SET description = replace(description, '" chercher "', '" remplacer_par "') WHERE description LIKE '%" chercher "%';" newline]
if continuer [
append sql_string tt 
print "Instruction SQL:"
print tt
]
not continuer
]
print sql_string

