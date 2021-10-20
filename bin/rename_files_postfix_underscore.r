#!/usr/bin/rebol -qs
rebol []
foreach f (read %.) [
 unless dir? f [
  rename (to-file f) (to-file rejoin [ f "_" ] ) 
 ]
]

