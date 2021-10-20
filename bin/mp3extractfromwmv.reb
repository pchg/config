#!/usr/bin/rebol -qs
rebol []
; conversion d'un .wmv en .mp3: juste une enveloppe pratique
file: system/options/args/1
;  file: "001-c_jam_blues_6_ella_and_count.wmv"
radical: replace file ".wmv" "" 
action_string: rejoin [ "mplayer -cache 128 -vc dummy -vo null -ao pcm -ao pcm:file=" radical ".pcm " radical ".wmv && lame " radical ".pcm " radical ".mp3"]
call/wait action_string

