#!/usr/bin/rebol -qs
Rebol [
	Title: "GREP betWEEN: greps between two text strings"
]
args: system/options/args
i: 0
foreach x args [
	i: i + 1
	print rejoin [i " " x]
]

file_in:    to-file   args/1
text_start: to-string args/2
text_end:   to-string args/3

file_in_port: open/string/lines file_in


if (find text_start file_in_port)



close file_in_port






