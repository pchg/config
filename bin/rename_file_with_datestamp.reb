#!/usr/bin/rebol -qs
rebol ["Quick utility to rename a file with a postfixed date = modified date"]
pad: func [ ;{{{ } } }
 "Pads a value with leading zeroes or a specified fill character."
  val [string! number!] n [integer!]
  /with c [char!] "Optional Fill Character"
][
  head insert/dup val: form val any [all [with c] #"0"] n - length? val
] ;}}}
if error? try [
msgerr: rejoin ["Error: no file specified as argument"]
if (system/options/args = none) [
	t msgerr quit]] [print msgerr quit]
file: system/options/args
print file
if error? try [
	msgerr: rejoin ["Error: file " file " can not be opened."]
	open to-file file
	print read/lines to-file file
	] [
	print msgerr quit
	]
d: to-date modified? to-file file
newfilename: rejoin [to-string file "_" d/year "_" pad d/month 2 "_" pad d/day 2 "_" replace replace to-string d/time ":" "h" ":" "m" "s"]
file: to-file file
newfilename: to-file newfilename
rename file newfilename
print rejoin ["File " file " has PROBABLY NOT (bug!) been renamed " newfilename]

