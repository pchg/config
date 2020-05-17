version 6.0
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
imap <F3>  :split#i
imap <F8> vip :w! /tmp/tmp_vim_block :!bash /tmp/tmp_vim_block i
imap <F6>  vip :w! /tmp/tmp_vim_block:!echo "rebol []" > /tmp/tmp_vim_block.rr && echo 'prin rejoin [newline "=>" {;======== code evaluation output: ========= }] ' >> /tmp/tmp_vim_block.rr && echo 'print "{{{"' >> /tmp/tmp_vim_block.rr && cat /tmp/tmp_vim_block.rr /tmp/tmp_vim_block > /tmp/tmp_vim_block.r && echo 'prin {;==========================================}' >> /tmp/tmp_vim_block.r && echo 'print " }}}" wait 0.1 print rejoin [newline {... Entrée pour continuer}] input' >> /tmp/tmp_vim_block.r && rebol -qs /tmp/tmp_vim_block.r}ki
imap <F5> :w :!./%i
inoremap <F7> :r !date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g' A 
inoremap <C-S-Down> 3i
inoremap <C-S-Up> 3i
inoremap <C-Down> ddpi
inoremap <C-Up> ddkPi
imap <M-Right> :wincmd li
imap <M-Left> :wincmd hi
imap <M-Down> :wincmd ji
imap <M-Up> :wincmd ki
inoremap <F14> Wi
inoremap <F13> i
inoremap <S-Tab> =CleverTabShift()
map <NL> 3
map  3
map  vip
nmap  :q
nmap  :w
map [3~ x
map OE i
map O5C w
map O5D b
map O5B ^F
map O5A ^B
map O2C w
map O2D b
map O2B ^F
map O2A ^B
map [3;5~ x
map [2;5~ i
map [3;2~ x
map [2;2~ i
map O5F $
map O5H 0
map O2F $
map O2H 0
map OF $
map OH 0
map [E i
map [D h
map [C l
map [B j
map [A k
map [4~ $
map [1~ 0
map [F $
map [H 0
map [6;5~ 
map [5;5~ 
map [6;2~ 
map [5;2~ 
map [6~ 
map [5~ 
map On .
map Op 0
map Os 3
map Or 2
map Oq 1
map Ov 6
map Ou 5
map Ot 4
map Oy 9
map Ox 8
map Ow 7
map OM 
map Ol ,
map Ok +
map Om -
map Oj *
map Oo :
map ! :if AutoHighlightToggle()|set hls|endif
map ,c :w:!aspell -c %:e %
map - <Home>i-- <Down><Home>
map ; <Home>i;<Down>
vmap gx <Plug>NetrwBrowseXVis
nmap gx <Plug>NetrwBrowseX
vnoremap <silent> <Plug>NetrwBrowseXVis :call netrw#BrowseXVis()
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#BrowseX(expand((exists("g:netrw_gx")? g:netrw_gx : '<cfile>')),netrw#CheckIfRemote())
map <F3> :split#
nnoremap <4-LeftMouse> vip
nnoremap <3-LeftMouse> vis
map <F8> vip :w! /tmp/tmp_vim_block :!bash /tmp/tmp_vim_block 
map <F6> vip :w! /tmp/tmp_vim_block:!echo "rebol []" > /tmp/tmp_vim_block.rr && echo 'prin rejoin [newline "=>" newline {;======== code evaluation output: ========= }] ' >> /tmp/tmp_vim_block.rr && echo 'print "{{{"' >> /tmp/tmp_vim_block.rr && cat /tmp/tmp_vim_block.rr /tmp/tmp_vim_block > /tmp/tmp_vim_block.r && echo 'prin {;==========================================}' >> /tmp/tmp_vim_block.r && echo 'print " }}}" wait 0.1 print rejoin [newline {... Entrée pour continuer}] input' >> /tmp/tmp_vim_block.r && rebol -qs /tmp/tmp_vim_block.r}k
map <F5> :w :!./%
map <F12> @@
map <F7> :r !date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g' A 
map <C-S-Down> 3
map <C-S-Up> 3
map <C-Down> ddp
map <C-Up> ddkP
map <M-Right> :wincmd l
map <M-Left> :wincmd h
map <M-Down> :wincmd j
map <M-Up> :wincmd k
map <F14> W
map <F13> 
map <S-F9> vip :w! /tmp/tmp_vim_block :!espeak -v en -s 200 -f /tmp/tmp_vim_block &
map <F9> vip :w! /tmp/tmp_vim_block :!espeak -v fr -s 200 -f /tmp/tmp_vim_block &
map <F10> vip :w! /tmp/tmp_current_paragraphdip<Up>:!aspell -c /tmp/tmp_current_paragraph :r /tmp/tmp_current_paragraph
inoremap 	 =CleverTab()
inoremap <NL> 3i
inoremap  3i
imap  :q
imap  :wi
map! [3~ <Del>
map! OE <Insert>
map! O5D <S-Left>
map! O5C <S-Right>
map! O5B <PageDown>
map! O5A <PageUp>
map! O2D <S-Left>
map! O2C <S-Right>
map! O2B <PageDown>
map! O2A <PageUp>
map! [3;5~ <Del>
map! [2;5~ <Insert>
map! [3;2~ <Del>
map! [2;2~ <Insert>
map! O5F <End>
map! O5H <Home>
map! O2F <End>
map! O2H <Home>
map! OF <End>
map! OH <Home>
map! [E <Insert>
map! [D <Left>
map! [C <Right>
map! [B <Down>
map! [A <Up>
map! [4~ <End>
map! [1~ <Home>
map! [F <End>
map! [H <Home>
map! On .
map! Op 0
map! Os 3
map! Or 2
map! Oq 1
map! Ov 6
map! Ou 5
map! Ot 4
map! Oy 9
map! Ox 8
map! Ow 7
map! OM 
map! Ol ,
map! Ok +
map! Om -
map! Oj *
map! Oo :
map £ <Home>i# <Down>
map ì :wincmd l
map è :wincmd h
map ê :wincmd j
map ë :wincmd k
let &cpo=s:cpo_save
unlet s:cpo_save
set backspace=indent,eol,start
set commentstring=%s
set fileencodings=ucs-bom,utf-8,default,latin1
set foldclose=all
set helplang=fr
set history=10000
set hlsearch
set ignorecase
set incsearch
set infercase
set keymodel=startsel,stopsel
set modelines=0
set mouse=a
set printoptions=paper:a4
set ruler
set runtimepath=~/.vim,/var/lib/vim/addons,/usr/share/vim/vimfiles,/usr/share/vim/vim81,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,~/.vim/after
set scrolloff=5
set shiftwidth=4
set showmatch
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set tabstop=4
set ttimeoutlen=100
" vim: set ft=vim :
