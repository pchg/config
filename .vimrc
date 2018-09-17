" Les touches de fonctions avec des raccourcis (à maintenir):
" F1  F2  F3  F4  F5  F6  F7  F8  F9  F10  F11  F12  F13  F14  F15  F16  F17  F18  F19  F20  
" -   -   |   -   |   |   |   |   |    |    -    |   -    -    -    -    -    -    -    -
" F3      \_ ouvre une fenêtre au-dessus avec l'occurrence précédente du mot sous le curseur
" F5              \_ sauver et faire tourner le fichier courant par rebol
" F6                  \_ faire tourner le paragraphe courant par rebol
" F7                      \_ insertion de timestamp, comme dans le bon vieux ultraedit
" F8                          \_ faire tourner le paragraphe courant par bash
" F9                              \_ dictée du paragraphe en cours
" shift-F9                        \_ shift => idem en anglais
" F10                                  \_ correction orthographique du paragraphe courant
" F12                                            \_ dernière macro

syntax on
set noautoindent
set ignorecase
set ruler
set showmatch
set showmode
" changes special characters in search patterns (default)
" set magic
set esckeys            " Required to be able to use keypad keys and map missed escape sequences

" get easier to use and more user friendly vim defaults
" CAUTION: This option breaks some vi compatibility. 
"          Switch it off if you prefer real vi compatibility
set nocompatible

" Complete longest common string, then each full match
" enable this for bash compatible behaviour
" set wildmode=longest,full

" Try to get the correct main terminal type/*{{{*/
if &term =~ "xterm"
    let myterm = "xterm"
else
    let myterm =  &term
endif
let myterm = substitute(myterm, "cons[0-9][0-9].*$",  "linux", "")
let myterm = substitute(myterm, "vt1[0-9][0-9].*$",   "vt100", "")
let myterm = substitute(myterm, "vt2[0-9][0-9].*$",   "vt220", "")
let myterm = substitute(myterm, "\\([^-]*\\)[_-].*$", "\\1",   "")
"/*}}}*/

" Here we define the keys of the NumLock in keyboard transmit mode of xterm/*{{{*/
" which misses or hasn't activated Alt/NumLock Modifiers.  Often not defined
" within termcap/terminfo and we should map the character printed on the keys.
if myterm == "xterm" || myterm == "kvt" || myterm == "gnome"
    " keys in insert/command mode.
    map! <ESC>Oo  :
    map! <ESC>Oj  *
    map! <ESC>Om  -
    map! <ESC>Ok  +
    map! <ESC>Ol  ,
    map! <ESC>OM  
    map! <ESC>Ow  7
    map! <ESC>Ox  8
    map! <ESC>Oy  9
    map! <ESC>Ot  4
    map! <ESC>Ou  5
    map! <ESC>Ov  6
    map! <ESC>Oq  1
    map! <ESC>Or  2
    map! <ESC>Os  3
    map! <ESC>Op  0
    map! <ESC>On  .
    " keys in normal mode
    map <ESC>Oo  :
    map <ESC>Oj  *
    map <ESC>Om  -
    map <ESC>Ok  +
    map <ESC>Ol  ,
    map <ESC>OM  
    map <ESC>Ow  7
    map <ESC>Ox  8
    map <ESC>Oy  9
    map <ESC>Ot  4
    map <ESC>Ou  5
    map <ESC>Ov  6
    map <ESC>Oq  1
    map <ESC>Or  2
    map <ESC>Os  3
    map <ESC>Op  0
    map <ESC>On  .
endif
"/*}}}*/

" xterm but without activated keyboard transmit mode/*{{{*/
" and therefore not defined in termcap/terminfo.
if myterm == "xterm" || myterm == "kvt" || myterm == "gnome"
    " keys in insert/command mode.
    map! <Esc>[H  <Home>
    map! <Esc>[F  <End>
    " Home/End: older xterms do not fit termcap/terminfo.
    map! <Esc>[1~ <Home>
    map! <Esc>[4~ <End>
    " Up/Down/Right/Left
    map! <Esc>[A  <Up>
    map! <Esc>[B  <Down>
    map! <Esc>[C  <Right>
    map! <Esc>[D  <Left>
    " KP_5 (NumLock off)
    map! <Esc>[E  <Insert>
    " PageUp/PageDown
    map <ESC>[5~ <PageUp>
    map <ESC>[6~ <PageDown>
    map <ESC>[5;2~ <PageUp>
    map <ESC>[6;2~ <PageDown>
    map <ESC>[5;5~ <PageUp>
    map <ESC>[6;5~ <PageDown>
    " keys in normal mode
    map <ESC>[H  0
    map <ESC>[F  $
    " Home/End: older xterms do not fit termcap/terminfo.
    map <ESC>[1~ 0
    map <ESC>[4~ $
    " Up/Down/Right/Left
    map <ESC>[A  k
    map <ESC>[B  j
    map <ESC>[C  l
    map <ESC>[D  h
    " KP_5 (NumLock off)
    map <ESC>[E  i
    " PageUp/PageDown
    map <ESC>[5~ 
    map <ESC>[6~ 
    map <ESC>[5;2~ 
    map <ESC>[6;2~ 
    map <ESC>[5;5~ 
    map <ESC>[6;5~ 
endif
"/*}}}*/

" xterm/kvt but with activated keyboard transmit mode./*{{{*/
" Sometimes not or wrong defined within termcap/terminfo.
if myterm == "xterm" || myterm == "kvt" || myterm == "gnome"
    " keys in insert/command mode.
    map! <Esc>OH <Home>
    map! <Esc>OF <End>
    map! <ESC>O2H <Home>
    map! <ESC>O2F <End>
    map! <ESC>O5H <Home>
    map! <ESC>O5F <End>
    " Cursor keys which works mostly
    " map! <Esc>OA <Up>
    " map! <Esc>OB <Down>
    " map! <Esc>OC <Right>
    " map! <Esc>OD <Left>
    map! <Esc>[2;2~ <Insert>
    map! <Esc>[3;2~ <Delete>
    map! <Esc>[2;5~ <Insert>
    map! <Esc>[3;5~ <Delete>
    map! <Esc>O2A <PageUp>
    map! <Esc>O2B <PageDown>
    map! <Esc>O2C <S-Right>
    map! <Esc>O2D <S-Left>
    map! <Esc>O5A <PageUp>
    map! <Esc>O5B <PageDown>
    map! <Esc>O5C <S-Right>
    map! <Esc>O5D <S-Left>
    " KP_5 (NumLock off)
    map! <Esc>OE <Insert>
    " keys in normal mode
    map <ESC>OH  0
    map <ESC>OF  $
    map <ESC>O2H  0
    map <ESC>O2F  $
    map <ESC>O5H  0
    map <ESC>O5F  $
    " Cursor keys which works mostly
    " map <ESC>OA  k
    " map <ESC>OB  j
    " map <ESC>OD  h
    " map <ESC>OC  l
    map <Esc>[2;2~ i
    map <Esc>[3;2~ x
    map <Esc>[2;5~ i
    map <Esc>[3;5~ x
    map <ESC>O2A  ^B
    map <ESC>O2B  ^F
    map <ESC>O2D  b
    map <ESC>O2C  w
    map <ESC>O5A  ^B
    map <ESC>O5B  ^F
    map <ESC>O5D  b
    map <ESC>O5C  w
    " KP_5 (NumLock off)
    map <ESC>OE  i
endif
"/*}}}*/

if myterm == "linux"
    " keys in insert/command mode.
    map! <Esc>[G  <Insert>
    " KP_5 (NumLock off)
    " keys in normal mode
    " KP_5 (NumLock off)
    map <ESC>[G  i
endif

" This escape sequence is the well known ANSI sequence for
" Remove Character Under The Cursor (RCUTC[tm])
map! <Esc>[3~ <Delete>
map  <ESC>[3~    x

" Only do this part when compiled with support for autocommands. /*{{{*/
if has("autocmd") 
  " When editing a file, always jump to the last known cursor position. 
  " Don't do it when the position is invalid or when inside an event handler 
  " (happens when dropping a file on gvim). 
  autocmd BufReadPost * 
    \ if line("'\"") > 0 && line("'\"") <= line("$") | 
    \   exe "normal g`\"" | 
    \ endif 
 
endif " has("autocmd")
"/*}}}*/

" Changed default required by SuSE security team--be aware if enabling this
" that it potentially can open for malicious users to do harmful things.
set modelines=0

" get easier to use and more user friendly vim defaults
" /etc/vimrc ends here

set hlsearch
set incsearch
set scrolloff=5
set mouse=a
set infercase
"set autoindent

" La correction orthographique, c'est très très bien
map ,c :w<CR>:!aspell -c %<CR>:e %<CR>
" Pour le paragraphe en cours:
map <F10> vip :w! /tmp/tmp_current_paragraph<cr>dip<up> :!aspell -c /tmp/tmp_current_paragraph<cr> :r /tmp/tmp_current_paragraph<cr> i<cr>

" La dictée, c'est très très bien aussi, pour le paragraphe en cours:
map <F9> vip :w! /tmp/tmp_vim_block<cr> :!espeak -v fr -s 200 -f /tmp/tmp_vim_block &<cr>

" Pareil, en anglais:
map <S-F9> vip :w! /tmp/tmp_vim_block<cr> :!espeak -v en -s 200 -f /tmp/tmp_vim_block &<cr>


"copié depuis /usr/share/doc/hibernate/examples/hibernate.vim.gz
   augroup filetypedetect
       au BufNewFile,BufRead hibernate.conf set filetype=hibernate
       au BufNewFile,BufRead common.conf set filetype=hibernate
       au BufNewFile,BufRead suspend2.conf set filetype=hibernate
       au BufNewFile,BufRead disk.conf set filetype=hibernate
       au BufNewFile,BufRead ram.conf set filetype=hibernate
   augroup END

set keymodel=startsel,stopsel


""""""""""""""""""""""""""""""""""""""""""""""""""
"à partir d'un vimrc trouvé sur la Toile:/*{{{*/
""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""
" Fichier .vimrc de Nicolas Gressier
" Créé le 11 mai 2006
" Yoshidu62@gmail.com
" Mise à jour : 03/06/2009
" Version 2.6
""""""""""""""""""""""""""""""""""""""""""""""""""

"Complétion par tabulation
""""""""""""""""""""""""""""""""""""""""""""""""""
function! CleverTab()
    "check if at beginning of line of after a space
    if strpart(getline('.'), 0, col('.')-1) =~ '^\s*$'
	return "\<Tab>"
    else
	"use know-word completion
	"return "\<C-N>"
	"use know-word completion, mais plutôt à l'envers
	return "\<C-P>"
    endif
endfunction

function! CleverTabShift()
    "check if at beginning of line or after a space
    if strpart(getline('.'), 0, col('.')-1) =~ '^\s*$'
	return "\<S-Tab>"
    else
	"use known-word completion, à l'endroit
	return "\<C-N>"
    endif
endfunction


"Mapping sur la touche Tab
"inoremap <Tab> <C-R>=CleverTab()<CR>

"et pareil sur la combinaison de touches Shift Tab:
"inoremap <S-Tab> <C-R>=CleverTabShift()<CR>

"Ctrl-Tab pour naviguer entre les fenêtres:
"MARCHE PAS ":map <C-Tab> <C-w><C-w>
"Marche =>
" http://stackoverflow.com/questions/2686766/mapping-c-tab-in-my-vimrc-fails-in-ubuntu
" ...
" Put this in your .vimrc:
" !! Important - instead of XXXX you must type CTRL-V and then Esc OR copy-paste the whole text and run %s/\(set <F1[34]>=\)XXXX/\=submatch(1) . "\33"/g which is copy-pastable (insert it with <CTRL-R> +).
set timeout timeoutlen=1000 ttimeoutlen=100
set <F13>=[27;5;9~
"nnoremap <F13> gt
map <F13> <C-w><C-w>
set <F14>=[27;6;9~
"nnoremap <F14> gT
"map <F14> :tabNext<CR>
map <F14> <C-w><S-w>
"And restart vim.
"Done.
" Pareil, pour le mode insertion (c'est quand même commode):
inoremap <F13> <Esc><C-w><C-w>i
inoremap <F14> <Esc><C-w><S-w>i


" Pour naviguer dans les onglets (bof):
":nmap <C-S-tab> :tabprevious<cr>
":nmap <C-tab> :tabnext<cr>
":nmap <C-t> :tabnew<cr>
":map <C-t> :tabnew<cr>
":map <C-S-tab> :tabprevious<cr>
":map <C-tab> :tabnext<cr>
":map <C-w> :tabclose<cr>
":imap <C-S-tab> <ESC>:tabprevious<cr>i
":imap <C-tab> <ESC>:tabnext<cr>i
":imap <C-t> <ESC>:tabnew<cr>

"/*}}}*/


"Ctrl-flèches pour déplacer les lignes, comme dans oOo:
"nnoremap <C-Up> ddkp <CR>	"DONE marche pas => si, ainsi:
map <C-Up>   ddkP
map <C-Down> ddp
inoremap <C-Up>   <Esc>ddkPi
inoremap <C-Down> <Esc>ddpi


" pour les folds chéris:
set foldmethod=marker
set fdc=5
set foldclose=all

"###################################################################################
" mapper F7 avec l'insertion de timestamp, comme dans le bon vieux ultraedit:
"brouillons:{{{
"map <F7> :r !date +\%d/\%m/\%Y\ \%T <Enter>
"07/10/2013 09:51:06
"map <F7> :r !date +\%d_\%m_\%Y__\%T \| sed -e 's/\:/_/g' <Enter>
"23_12_2013__15_48_43
"map <F7> :r !date +\%Y_\%m_\%d__\%T \| sed -e 's/\:/_/g' <Enter>
"2013_12_29__20_29_38

" Je mets la date en ISO 8601, plutôt:
":r !date +\%Y_\%m_\%d__\%T 
"2014_01_01__21:55:01
":r !date +\%Y-\%m-\%d_\%T 
"2014-01-01_21:55:51
"map <F7> :r !date +\%Y-\%m-\%d_\%T \| sed -e 's/\:/h/' \| sed -e 's/\:/m/' <Enter>
"non, plutôt en ISO underscoré, comme dans le .bashrc:
"map <F7> :r !date +\%Y_\%m_\%d__\%T \| sed -e 's/\:/_/g' <Enter>
"map <F7> :r!date +\%Y_\%m_\%d__\%T \| sed -e 's/\:/h/' \| sed -e 's/\:/m/'<Enter>
"2014_01_03__14h45m36
"2014_01_07__16h34m19
"}}}
map <F7> :r !date +\%Y_\%m_\%d__\%T \| sed -e 's/\:/_/g' <Enter>A 
"inoremap <F7> <Esc>:r !date +\%Y_\%m_\%d__\%T \| sed -e 's/\:/_/g' <Enter>A 
"2014_01_14__08_53_38
"###################################################################################

"mapper F10 avec la ligne courante à faire tourner en tant que commande vi (:)
"map <F10> <Esc>V<Left><Home>:<S-Ins><Enter>
" => marche pas...


"mapper F12 avec la dernière macro:
map <F12> @@

set history=10000

set encoding=utf-8
set fileencoding=utf-8


"highlighter toutes les occurrences du mot sous le curseur:/*{{{*/
"http://vim.wikia.com/wiki/Auto_highlight_current_word_when_idle
"
"created 2003 · complexity basic · author mosh · version 6.0
"Vim can easily highlight all search pattern matches and search for the current word (the word under the cursor). This tip shows how to automatically highlight all occurrences of the current word without searching. That can be useful when examining unfamiliar source code: just move the cursor to a variable, and all occurrences of the variable will be highlighted.
"
"
" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=4000
    echo 'Highlight current word: off'
    return 0
  else
    augroup auto_highlight
      au!
      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup end
    setl updatetime=500
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction
" on fait ça avec... ! (pas loin de *)
map ! :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
" non, plutôt avec... µ (maj - *)
" => marche pas 
":map <S-*> :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
" ni <C-*> ni <S-C-*> ni <S-*> ... donc retour au !

"/*}}}*/

" Des couleurs de vimdiff un peu plus humainement lisibles pour un presse-b!t3:
highlight DiffAdd    ctermbg=6
highlight DiffChange ctermbg=2
highlight DiffDelete ctermbg=6
highlight DiffText   ctermfg=1 ctermbg=2 cterm=bold

"quelques conseils de http://vim.wikia.com/wiki/Using_standard_editor_shortcuts_in_Vim; fait un peu (beaucoup!) de ménage, quand même:

"set smartindent
set tabstop=4
set shiftwidth=4
"set expandtab

"set mouse=a
"set nu

":map <C-a> GVgg
":map <C-n> :enew
":map <C-o> :e . <Enter>
":map <C-s> :w <Enter>
":map <C-c> y
":map <C-v> p
":map <C-x> d
":map <C-z> u
":map <C-t> :tabnew <Enter>
":map <C-i> >>
":map <C-w> :close <Enter>
":map <C-W> :q! <Enter>
":map <C-f> /
":map <C-h> :%s/
":map <S-t> vat
":map <S-T> vit
":map <S-{> vi{
":map <S-(> vi(
":map <S-[> vi[

"Je me fais des raccourcis pour les Fn:
":map <F1>
":map <F2>
":map <F3> n
":map <F4>


"pour sauver et faire tourner le fichier courant par rebol^W n'importe quoi, pourvu que le chebang soit bien fait:
"to save and run the current file by rebol^W interpreter^W anything, as long as the shebang is correct:
"map <F5> :w<cr> :!rebol -qs %<cr>
map <F5> :w<cr> :!./%<cr>

""pour faire tourner la sélection courante par rebol:
""to interpret the current visual selection by rebol interpreter:
":map <F6> :w! tmp_vim_block<cr> :!echo "rebol []" > tmp_vim_block.rr && cat tmp_vim_block.rr tmp_vim_block > tmp_vim_block.r && rebol -qs tmp_vim_block.r && rm tmp_vim_block.rr tmp_vim_block.r tmp_vim_block<cr>

"mieux:
"even better: 

"pour faire tourner le paragraphe courant par rebol:
"to interpret the current paragraph by rebol interpreter:
":map <F6> vip :w! tmp_vim_block<cr> :!echo "rebol []" > tmp_vim_block.rr && cat tmp_vim_block.rr tmp_vim_block > tmp_vim_block.r && rebol -qs tmp_vim_block.r && rm tmp_vim_block.rr tmp_vim_block.r tmp_vim_block<cr>

"map <F6> vip :w! /tmp/tmp_vim_block<cr>:!echo "rebol []" > /tmp/tmp_vim_block.rr && echo 'prin rejoin [newline "=>" newline {;======== code evaluation output: ========= } ]' >> /tmp/tmp_vim_block.rr && echo "{{{" >> /tmp/tmp_vim_block.rr  && cat /tmp/tmp_vim_block.rr /tmp/tmp_vim_block > /tmp/tmp_vim_block.r && echo "prin {;==========================================} && echo "}}}" wait 0.5 print rejoin [newline newline newline {Entrée pour continuer}] input" >> /tmp/tmp_vim_block.r && rebol -qs /tmp/tmp_vim_block.r<cr>}k
"map <F6> vip :w! /tmp/tmp_vim_block<cr>:!echo "rebol []" > /tmp/tmp_vim_block.rr && echo 'print rejoin [newline "=>" newline {;======== code evaluation output: =========} ]' >> /tmp/tmp_vim_block.rr  && cat /tmp/tmp_vim_block.rr /tmp/tmp_vim_block > /tmp/tmp_vim_block.r && echo "print {;==========================================} wait 0.5 print rejoin [newline newline newline {Entrée pour continuer}] input" >> /tmp/tmp_vim_block.r && rebol -qs /tmp/tmp_vim_block.r<cr>}k

map <F6> vip :w! /tmp/tmp_vim_block<cr>:!echo "rebol []" > /tmp/tmp_vim_block.rr && echo 'prin rejoin [newline "=>" newline {;======== code evaluation output: ========= }] ' >> /tmp/tmp_vim_block.rr && echo 'print "{{{"' >> /tmp/tmp_vim_block.rr && cat /tmp/tmp_vim_block.rr /tmp/tmp_vim_block > /tmp/tmp_vim_block.r && echo 'prin {;==========================================}' >> /tmp/tmp_vim_block.r && echo 'print " }}}" wait 0.1 print rejoin [newline newline {... Entrée pour continuer}] input' >> /tmp/tmp_vim_block.r && rebol -qs /tmp/tmp_vim_block.r<cr>}k

"pour commenter une ligne de code Rebol et passer à la suivante:
map ; <Home>i;<Esc><Down>

"pour commenter une ligne de code, genre shell script, par # passer à la suivante:
":map &; <Home>i#<Esc><Down>
" => marche pas...
map £ <Home>i#<Esc><Down>

"pour commenter une ligne de code SQL et passer à la suivante:
map - <Home>i--<Space><Esc><Down><Home>


"Et un raccourci pour sélectionner un Paragraphe:
map <C-S-p> vip
"(enlevé <S-p> qui fait paste avant)

" pour faire tourner le paragraphe courant par bash:
map <F8> vip :w! /tmp/tmp_vim_block<cr> :!bash /tmp/tmp_vim_block <cr>


" Pour sélectionner divers bidules par des double (non, déjà fait)
"<LeftMouse>     - Left mouse button press
"<RightMouse>    - Right mouse button press
"<MiddleMouse>   - Middle mouse button press
"<LeftRelease>   - Left mouse button release
"<RightRelease>  - Right mouse button release
"<MiddleRelease> - Middle mouse button release
"<LeftDrag>      - Mouse drag while Left mouse button is pressed
"<RightDrag>     - Mouse drag while Right mouse button is pressed
"<MiddleDrag>    - Mouse drag while Middle mouse button is pressed
"<2-LeftMouse>   - Left mouse button double-click
"<2-RightMouse>  - Right mouse button double-click
"<3-LeftMouse>   - Left mouse button triple-click
"<3-RightMouse>  - Right mouse button triple-click
"<4-LeftMouse>   - Left mouse button quadruple-click
"<4-RightMouse>  - Right mouse button quadruple-click
"<X1Mouse>       - X1 button press
"<X2Mouse>       - X2 button press
"<X1Release>     - X1 button release
"<X2Release>     - X2 button release
"<X1Drag>        - Mouse drag while X1 button is pressed
"<X2Drag>        - Mouse drag while X2 button is pressed

"  - Right mouse button triple-click => sélectionne déjà une ligne, je laisse.

"pour sélectionner une phraSe:
:nnoremap <3-LeftMouse> vis
"pour sélectionner un Paragraphe (comme ctrl-P):
:nnoremap <4-LeftMouse> vip


"Un raccourci similaire à *, mais avec shift, ça fait µ, qui
"ouvre une autre fenêtre puis fait un *
" => très utile pour les tags
" => mince, pas pu faire :map <S-*> :split <cr>*
"                  ni:   :map <µ> :split <cr>*
"donc je fais avec F3, et vers le haut, c'est plus commode, avec #:
:map <F3> :split <cr>#




"Pour PAS ne pas recommencer la recherche au début/fin du fichier:
":set nowrapscan 
"Pour ne pas recommencer la recherche au début/fin du fichier:
:set wrapscan

"le plus souvent, le wrap m'emmerdoie, pour des sources bien indentés notamment; donc j'ôte:
:set nowrap
"mais des fois, il rend service..
:set wrap

"Pour ôter les /* */ disgrâcieux de mes folds {{{ }}} ou [ ]
:set commentstring=%s


"Réticule;
""Pour avoir un réticule amusant (et utile):
":set cursorcolumn
":set cursorline
"
""Pour mettre du grisé dans les 2 axes du réticule (car le soulignement de l'axe horizontal gêne quelque peu la lecture):
":hi CursorLine cterm=NONE
"":hi CursorLine ctermbg=Cyan
":hi CursorLine ctermbg=Grey
"":hi CursorColumn ctermbg=Cyan
"
"=> En fait, dès qu'on est dans un ssh quelconque, ou une console, ce réticule est giga-chiasseur: zou, je le zappe.

"syntaxe Rebol:
:set syntax=rebol
"aussitôt désactivée:
:set syntax=none
"=> c'est pour avoir les complétions judicieuses, les mots avec des - vus comme un seul mot (ce qui est commode), mais sans avoir les couleurs (qui n'aident pas forcément beaucoup).

