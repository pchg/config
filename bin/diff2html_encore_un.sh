#!/bin/bash
#
# colorize diff output for ANSI terminals
# based on "diff2html" 
# (http://www.linuxjournal.com/content/convert-diff-output-colorized-html)

# absolute color definitions
NOCOL="\e[0m"
BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
PINK="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"

# style color definitions
C_COMMENT=$WHITE
C_DIFF=$RED
C_OLDFILE=$CYAN
C_NEWFILE=$RED
C_STATS=$GREEN
C_OLD=$BOLD$RED
C_NEW=$BOLD$GREEN
C_ONLY=$PINK

# check args
[[ $# -lt 2 ]] && echo "Usage: $0  " && exit 1

# The -r option keeps the backslash from being an escape char.
diff -u $@ | while read -r s ; do
	# determine line color
	if [[ "${s:0:7}" == 'Only in' ]]; then color=$C_ONLY
	elif  [[ "${s:0:4}" == 'diff' ]]; then color=$C_DIFF
	elif  [[ "${s:0:3}" == '---'  ]]; then color=$C_OLDFILE
	elif  [[ "${s:0:3}" == '+++'  ]]; then color=$C_NEWFILE
	elif  [[ "${s:0:2}" == '@@'   ]]; then color=$C_STATS
	elif  [[ "${s:0:1}" == '+'    ]]; then color=$C_NEW
	elif  [[ "${s:0:1}" == '-'    ]]; then color=$C_OLD
	else color=
	fi

	# Output the line.
	if [[ "$color" ]]; then
		printf "$color"
		echo -n $s
		printf "$NOCOL\n"
	else echo $s
	fi
done
