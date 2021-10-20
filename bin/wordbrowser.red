#!/home/pierre/bin/red
Red [
	Title: "RED Word Browser (Dictionary)"
	Author: "Carl Sassenrath et al."
;	Version: 2020.04.14
	history: [
		2.0.1 12-Sep-2005 "Carl" {First release on the web}
		2.1.0 16-Sep-2005 "Didier Cadieu" {Resizing and mouse wheel handling.}
		2.1.1 17-Sep-2005 "Gregg Irwin" {Minor UI tweaks - top bar height, func summary/bkgnd color}
		20.4.14 14-Apr-2020 "Pib" {Let's begin migrating this to Red}
	]
]

if lesser? system/version 0.6.4 [alert "Requires View 1.3.1 or better" quit]
; TODO correct URL:
if not exists? %word-cats.red [write %word-cats.red read http:re-bol.com/word-cats.r]
; TODO correct URL:
if not exists? %word-defs.red [write %word-defs.red read http:re-bol.com/word-defs.r]
;__________________

*word-marker: none

;-- Provide proxy functions for words that would cause GUI problems:

*isolator: context [

	view: func
		first get in system/words 'view
		head insert copy/deep second get in system/words 'view [new: true]

]

*word-browser: context [

site-url: http://www.rebol.com/docs/
dict-file: %word-defs.r
cmts-file: %word-cmts.r
cats-file: %word-cats.r

temp-files: [] ;%word-defs-new-carl.r %word-defs-new-gregg.r
end-cats: [not-found internal]
word-stack: []
this-word: word-stack
ref: []
cats-list: none


;-- GUI for scrollable function description area:

body-style: code-style: link-style: xy: none
out-lay: [] ; build word layout here

style-layout: layout [
	body-style: txt
	link-style: txt bold font [
		colors: reduce [maroon red]
		color: first colors
		style: [underline bold]
	][
		face/font/color: first face/font/colors ; patch
		show-word face/user-data
	]
	code-style: tt bold black 220.220.220
		font [colors: reduce [black blue]]
		para [origin: 2x8 margin: 2x8]
		edge [size: 1x1 color: gray + 40]
		[attempt [do bind load face/text *isolator]]
	head-style: h3 400x25 bottom 16.48.160
	cmt-btn: btn-enter "Add Comment" [add-comment]
]

; Patch for better text-list resizing / Didier
svv/vid-styles/text-list/resize: func [new /x /y /local tmp] bind [
	either any [x y] [
		if x [size/x: new] 
		if y [size/y: new]
	] [
		size: any [new size]
	] 
	pane/size: sz: size 
	sld/offset/x: first sub-area/size: size - 16x0 
	sld/resize/y: size/y 
	iter/size/x: first sub-area/size - sub-area/edge/size 
	lc: to-integer sz/y / iter/size/y
	sld/redrag lc / max 1 length? data
	;*** Here is the changes : recompute the list position and resync dragger bar
	sn: max 0 min sn tmp: 1 - lc + length? data
	sld/data: sn / max 1 tmp
	self
] svv/vid-styles/text-list

reset-layout: does [
	clear out-lay
	xy: 16x0
]

make-text: func [
	"Make a section of text"
	str style indent /link
	/local face word
][
	if link [word: str str: form str]
	face: make-face style
	face/text: str
	face/line-list: none
	;face/color: yellow
	face/size: f-info/size - (indent * 1x0) - xy/x      ; in sync for resizing
	face/size/y: face/para/origin/y + face/para/margin/y + second size-text face 
	if link [face/user-data: :word  face/size/x: 4 + first size-text face]
	face/offset: indent * 1x0 + xy
	xy/y: xy/y + face/size/y
	if not link [xy: xy + 0x6]
	append out-lay face
]

make-arg: func [
	"Create an argument entry in function arg table"
	arg-word arg-info type-info
	/local pane sz szp
][
	szp: as-pair min 520 f-info/size/x - xy/x  34   ;size of full arg box
	sz: as-pair min 440 szp/x - 82  -1              ;size of description lines

	pane: layout [
		size szp
		style txt txt font-size 11 para [origin: margin: 2x1]
		origin 0 space 0

		;-- Argument word:
		txt mold arg-word 80x34 bold black
			either refinement? arg-word [sky][240.240.180]
			center middle 

		;-- Argument description:
		at 80x0
		txt sz bold black snow middle
			either arg-info [form arg-info][
				reform ["The" arg-word pick ["refinement." "argument."] refinement? arg-word]
		]

		;-- Argument datatype:
		txt sz black 200.220.200 middle
			either refinement? arg-word ["A refinement."][
				join "Accepts: " either type-info [reform type-info]["anything"]
		]
		sz: at
	]
	pane/size/y: 2 + pane/pane/1/size/y: sz/y   ; resize verticaly if wrap has occured
	
	pane/edge: make pane/edge [size: 1x1 color: gray + 40]
	pane/color: snow
	pane/offset: xy
	xy/y: xy/y + pane/size/y - 2 ; edge height
	append out-lay pane
]

make-heading: func [title] [
	append-face make head-style [text: title]
]

pad-space: func [y] [xy/y: xy/y + y]

append-face: func [face] [
	face/offset/y: xy/y
	face/offset/x: 0
	xy/y: xy/y + face/size/y + 6 ;12
	append out-lay face
]

make-body-text: func [str] [make-text str body-style 0]
make-code-text: func [str] [make-text str code-style 2]
make-link: func [word] [make-text/link word link-style 10]

show-info: func [title summary text] [
	f-name/text: title
	f-args/text: none
	f-summary/text: summary
	f-name/size/x: 400
	reset-layout
	replace/all text "^/^/" "~"
	text: parse/all text "~"
	foreach txt text [
		make-body-text trim/lines txt
	]
	show main
]

;-- Function description parser:

code: text: none
space: charset " ^-"
chars: complement charset " ^-^/"
rules: [some parts]
parts: [
	  newline
	| example
	| paragraph
]
example: [
	copy text some [indented | some newline indented]
	(make-code-text trim/tail text)
]
paragraph: [copy text some [chars thru newline] (make-body-text trim/lines text)]
indented:  [some space thru newline]

spec-parser: context [
	data: f-cmt: f-atr: a-word: a-types: a-cmt: a-ref: a-ref-cmt: f: h: none
	fun-cmt: [set val string! (f-cmt: val)]
	fun-atr: [set val block!  (f-atr: val)]
	fun-intro: [(f-cmt: f-atr: none) fun-cmt opt fun-atr | fun-atr opt fun-cmt | none (f-cmt: "")]
	arg-word: [
		set a-word [
			word! (f: :to-word)
			| get-word! (f: :to-get-word)
			| lit-word! (f: :to-lit-word)
		]
		(a-word: f a-word)
	]
	arg-types: [set a-types block!]
	arg-cmt: [set a-cmt string!] 
	fun-arg: [
		(a-types: a-cmt: none)
		arg-word opt arg-types opt arg-cmt
		(repend data [a-word a-cmt a-types])
	]
	ref-word: [set a-ref refinement! h: (if a-ref = /local [h: tail h]) :h]
	ref-cmt: [set a-ref-cmt string!]
	fun-spec: [
		opt [fun-intro (repend data [f-cmt f-atr])]
		any fun-arg
		any [ (a-ref-cmt: none)
			ref-word
			opt ref-cmt (if a-ref <> /local [a-ref-cmt repend data [a-ref a-ref-cmt none]])
			any fun-arg
		]
	]
	set 'parse-spec func [word] [
		data: reduce [word]
		parse third get word fun-spec
		data  ; word comment attr  some [arg-word comment type]
	]
]

;-- Word list builder:

words: []
search-text: none

filter-words: func [
	type
	/list wrds
	/local new-words
][
	if not list [show-category type]
	case [
		type = first end-cats [words: missing-words]
		type = 'all [words: extract ref 2]
		list [words: wrds]
		true [
			clear words
			foreach [word def] ref [
				if all [block? def/1 find def/1 type] [append words word]
			]
		]
	]
	if value? 'f-funcs [
		f-funcs/texts: f-funcs/lines: f-funcs/data: words
		f-funcs/sn: f-funcs/sld/data: 0
		f-funcs/sld/redrag f-funcs/lc / max 1 length? words
		show f-funcs
	]
]

missing-words: has [
	"Return list of words that are missing from dictionary."
	words sys-words sys-vals
][
	words: make block! 40
	sys-words: first system/words
	sys-words: copy/part sys-words back find sys-words '*word-marker
	sys-vals: second system/words
	foreach word sys-words [
		if all [
			not find ref word
			any-function? first sys-vals
		][append words word]
		sys-vals: next sys-vals
	]
	bind sort words 'system
]

search-words: func [text /local words tmp got] [
	unselect-lists
	words: clear []
	foreach [word def] ref [
		if find tmp: form word text [
			if tmp = text [got: word]
			append words word
		]
	]
	filter-words/list none words
	got
]

;-- The Main Window GUI:

h: none
wh: 0x500 ; height of description area
bh: wh + 0x46 ; height of lists
words: []
types: []

f-word: b-bk: b-fd: f-cats: f-funcs: f-name: f-args: f-summary: f-info: f-slid: f-bar: f-tools: none

main: layout [
	origin 0 space 0x0
	backcolor snow - 10

	style bbar text white 20x24 40.40.80 bold middle

	;-- Top Bar for Subjects and Buttons:
	across
	lab 50 "Find:" black gold effect compose [gradient 0x1 gold (gold - 50)]
	f-word: field 180 "" edge [size: 1x1] middle
	h: at
	b-bk: box 20x24 40.40.80 effect [draw [line-width .01 fill-pen gold triangle 5x10 17x3 17x17] grayscale] [back-ref-word]
	b-fd: box 20x24 40.40.80 effect [draw [line-width .01 fill-pen gold triangle 3x3 3x17 15x10] grayscale] [next-ref-word]
	f-bar: bbar 552x24 - 40x0 - 100x0
	f-tools: panel [
		space 0x0 across
		bbar "*" [launch/quit system/options/script]
		bbar 40x24 "Print" [alert "Not available yet."]
		bbar 40x24 "Prefs" [alert "Not available yet."]
	]
	return
	bbar 100x20 "Categories" 
	pad 1x0
	bbar 130x20 - 1x0 "Words" 
	pad 1x0
	return

	;-- Category and Word Lists:
	f-cats:  text-list bold 16.48.160 100x0 + bh data types [filter-words value]
	f-funcs: text-list bold 130x0 + bh data words [show-word value] return
	return

	;-- Function Details:
	at h + 6x26 guide
	f-name: h1 400x28 160.0.0
	pad 0x2
	f-args: h2 italic 36x24 bottom return
	pad 2x0
	f-summary: txt 100.100.100 bold 500 "a^/a" as-is return
	f-info: box 524x0 + wh snow ;edge [size: 1x1 color: silver]

	;-- Scroll bar:
	at f-info/offset + (f-info/size * 1x0) + 6x0
	f-slid: scroller 16x0 + wh [
		scroll-box/offset/y: negate value * (scroll-box/size/y - f-info/size/y) show f-info
	]
	do [f-slid/redrag 1]
	return

	key keycode [up]   [pick-back] 
	key keycode [down] [pick-next] 
	key keycode [left] [back-ref-word] 
	key keycode [right] [next-ref-word] 
	key keycode escape [quit] 
]

;-- Main window event handling (resize and mouse wheel scroll)
; store needed values here
main/user-data: reduce ['size main/size 'mouse 0x0]

main/feel: make main/feel [
	detect: func [face event /local tl nb] [
		switch event/type [
			key [   ; handle the standard window feel for 'key event
				if face: find-key-face face event/key [
					if get in face 'action [do-face face event/key]
					event: none
				]
			]

			; mouse position must be stored somewhere for 'scroll-line event
			move [face/user-data/mouse: event/offset]
			
			scroll-line [
				if within? face/user-data/mouse f-cats/offset f-cats/size [tl: f-cats]
				if within? face/user-data/mouse f-funcs/offset f-funcs/size [tl: f-funcs]
				all [tl  scroll-text-list tl event/offset/y  event: none]
				if f-cats/size/x + f-funcs/size/x < face/user-data/mouse/x [
					nb: scroll-box/offset/y - (event/offset/y * 20)
					scroll-box/offset/y: nb: min 0 max nb f-info/size/y - scroll-box/size/y
					f-slid/data: nb / min -1 f-info/size/y - scroll-box/size/y
					show [f-info f-slid]
					event: none
				]
			]
			
			resize [
				nb: face/size - face/user-data/size     ; compute size difference
				face/user-data/size: face/size          ; store new size
				f-bar/size/x: f-bar/size/x + nb/x
				f-tools/offset/x: f-tools/offset/x + nb/x
				f-cats/resize/y f-cats/size/y + nb/y
				f-funcs/resize/y f-funcs/size/y + nb/y
				f-name/size/x: f-summary/size/x: f-summary/size/x + nb/x
				f-info/pane/size/x: first f-info/size: f-info/size + nb
				f-slid/resize/y f-slid/size/y + nb/y
				f-slid/offset/x: f-slid/offset/x + nb/x
				f-slid/redrag f-info/size/y / scroll-box/size/y
				either this-word/1 [show-word this-word/1][show main]
				event: none
			]
		]
		event
	]
]

scroll-text-list: func [
	{scroll a text-list by some lines}
	tl lines /local tmp
] [
	tmp: 1 - tl/lc + length? tl/data
	tl/sn: max 0 min tmp lines + tl/sn
	tl/sld/data: max 0.0 min 1.0 tl/sn / tmp
	show tl
]

scroll-box: make-face f-info
f-info/pane: scroll-box
scroll-box/edge: none
scroll-box/offset: 0x0
scroll-box/pane: out-lay
focus f-word

f-word/feel: make f-word/feel [
	; Used for the incremental FIND field:
	redraw: func [face act pos][
		face/color: pick face/colors face <> system/view/focal-face
		if all [
			face = system/view/focal-face
			face/text <> search-text
		][
			search-text: copy face/text
			if any [
				value: search-words face/text
				1 = length? words
			][
				show-word any [value words/1]
			]
		]
	]
]

gray-arrow: func [face cond] [
	; Make back/fwd arrows gray:
	remove find face/effect 'grayscale
	if cond [insert tail face/effect [grayscale]]
]

unselect-lists: does [
	clear f-cats/picked
	clear f-funcs/picked
	show [f-cats f-funcs]
]

show-category: func [type /local cat] [
	cat: select cats-list type
	if any [not cat tail? cat] [cat: ["No summary." ""]]
	if tail next cat [append cat ""]
	show-info uppercase/part form type 1 cat/1 cat/2
]

pick-next: has [f] [
	f: all [f-funcs/picked f-funcs/picked/1]
	either none? f [f-funcs/picked: reduce [f-funcs/data/1]][
		f: find f-funcs/data f
		if tail? next f [exit]
		f-funcs/picked: reduce [first f: next f]
	]
	sync-funcs-list index? f
	show-word first f-funcs/picked
	show f-funcs
]

pick-back: has [f] [
	f: all [f-funcs/picked f-funcs/picked/1]
	either none? f [f-funcs/picked: reduce [f-funcs/data/1]][
		f: find f-funcs/data f
		f-funcs/picked: reduce [first f: back f]
	]
	sync-funcs-list index? f
	show-word first f-funcs/picked
	show f-funcs
]

sync-funcs-list: func [
	{scroll the functions list if the selected word is out of the viewed area}
	pos
] [
	f-funcs/sn: min f-funcs/sn pos - 1
	f-funcs/sn: max f-funcs/sn pos - f-funcs/lc
	f-funcs/sld/data: f-funcs/sn / (1 - f-funcs/lc + length? f-funcs/data)  
]

;-- Dictionary word description GUI:
 
show-word: func [word /local attr also desc cmts lst args type] [
	if none? word [exit]

	if word <> this-word/1 [
		insert this-word: tail this-word word
	]

	gray-arrow b-bk head? this-word
	gray-arrow b-fd tail? next this-word

	set [attr also desc cmts] select ref word

	;-- Generate list of args (without refinements):
	either all [
		value? word
		any-function? get word
	][
		lst: parse-spec word
		args: copy []
		foreach [word a b] skip lst 3 [
			if refinement? word [break]
			append args word
		]
	][
		args: []
		type: type? either value? word [get word][word]
		lst: reduce ["" reform ["Datatype:" type]]
	]
	;-- Set word, arguments, and summary:
	f-name/text: form word
	f-args/text: trim/lines mold/only args
	f-args/offset/x: f-name/offset/x + 4 + first size-text f-name
	f-args/size/x: 300
	f-summary/text: trim/lines lst/2

	;-- Reset layout:
	reset-layout

	;-- Argument section:
	if not tail? skip lst 3 [
		make-heading "Arguments:"
		foreach [word cmt type] skip lst 3 [make-arg word cmt type]
		pad-space 8
	]

	;-- Description section:
	make-heading "Description:"
	either desc [parse/all detab desc rules][
		make-body-text "No description provided. To be added."
	]

	if also [
		make-heading "See Also:"
		sort also
		foreach word also [make-link word]
	]

	;-- Comment section:
	if any [cmts select ref-cmts word] [
		make-heading "User Comments:"
		if cmts [
			parse/all detab cmts rules
		]
		if cmts: select ref-cmts word [
			parse/all detab cmts rules
		]
	]
	pad-space 8
	append-face cmt-btn

	;-- Reset scroll bar:
	scroll-box/size/y: xy/y
	f-slid/data: 0.0
	f-slid/redrag f-info/size/y / max 1 scroll-box/size/y
	f-info/pane/offset/y: 0
	show main
]

back-ref-word: does [
	unselect-lists
	this-word: back this-word
	show-word this-word/1
]

next-ref-word: does [
	unselect-lists
	this-word: next this-word
	if tail? this-word [this-word: back this-word]
	show-word this-word/1
]

;-- Post comment (needs revision):

cmt-lay: none

add-comment: has [] [
	alert "Not available yet" exit
	if none? cmt-lay [
		cmt-lay: layout [
			;styles link-styles backdrop
			h2 300
			new-cmt: area "" 400x300 wrap
			across
			button "Save" [
				hide-popup
				repend new-cmt/text [newline newline]
				either "ok" <> post-server reduce ['reference this-word new-cmt/text][
					request/ok "Unable to access server. Posting failed."
				][
					entry: select ref-cmts this-word
					insert new-cmt/text reduce ["^/^/-From: " user-prefs/name " [pending]^/^/"]
					either entry [append entry new-cmt/text entry][repend ref-cmts [this-word new-cmt/text]]
				]
				show-word this-word
			]
			button "Cancel" [hide-popup]
		]
	]
	cmt-lay/pane/2/text: reform ["Add comments to:" this-word]
	clear new-cmt/text
	new-cmt/line-list: none
	focus new-cmt
	inform cmt-lay
]

;-- Load data files:

reload: func [file] [
	; Load and decompress a file:
	if not exists? file [
		all [
			data: request-download site-url/:file
			data: attempt [decompress data]
			attempt [write/binary file data]
		]
	]
	if not data: attempt [load file] [
		alert reform ["Problem loading file:" file " - cannot continue."]
		quit
	]
	data
]

load-files: has [cats] [

	if not all [
		exists? dict-file
		exists? cats-file
	][
		if not confirm {The REBOL dictionary datafiles must be downloaded
			for you to continue. Download them now?} [
			quit
		]
	]

	ref: reload dict-file
	cats-list: reload cats-file

	ref-cmts: either exists? cmts-file [load cmts-file][copy []]
	foreach f temp-files [append ref load f]

	cats: []
	foreach [word desc] ref [
		if select ref-cmts word [
			if not find desc/1 #commented [append desc/1 #commented]
		]
		if block? desc/1 [append cats desc/1]
	]
	cats: unique cats
	sort cats
	remove find cats 'internal
	insert cats 'all
	append cats end-cats
	insert clear f-cats/data cats
	show main
]

;-- Bring it up:

show-info "REBOL Word Browser" 
"An interactive dictionary for REBOL." {
Type a word into the search field for a quick lookup.

Or, click on the category, then select a word to see information about it.

The not-found category finds words that have not yet been documented in the
dictionary.

Click examples to evaluate them.

Arrow keys move between entries and backward/forward.

The internal category lists words that are internal to REBOL.

We will add the user comment method, printing, prefs and more.
}

view/new/options center-face main [resize min-size 600x400]
load-files
make-dir %temp-examples/
change-dir %temp-examples/

do-events

]
