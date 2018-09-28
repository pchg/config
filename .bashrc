export TERM=xterm

if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi

alias ls='ls --color=auto'
alias ll='ls -lh'
alias dir='ll'
alias la='ll -a'
alias l='ls -alFh'
alias ls-l='ls -l'
alias lll='ls -trlh | less'
alias lla='ll -a | less'
alias lls='ls -trlh | tail -10'
alias llls='ls -trlh | tail -40'

alias der_fichier='ls --group-directories-first -Htr | tail -1'

# des progs amoin; au lieu de faire un mini-script à chaque fois:
alias qe='wine ~/progswin/util/qe.exe'
alias vb='wine ~/progswin/vb3/vb.exe'
alias acrobat5='wine ~/progswin/Acrobat_5.0/Acrobat/Acrobat.exe'
alias autocadmap3='wine ~/progswin/autocadmap3/acad.exe'
alias arcview='wine ~/progswin/av_gis30/arcview/bin32/arcview.exe'
alias gdm42b='wine ~/progswin/gdm42b/wingdm.exe'
#                                     gdm42b.bat'
alias mapfinfo75='wine ~/progswin/mapinfo_75/MAPINFOW.EXE'
alias norton_commander_win='wine ~/progswin/nc_w/nc.exe'
alias geoser='wine ~/progswin/sermine/geoser.exe'
alias msqry='wine ~/progswin/util/msqry32.exe'
alias nc='wine ~/progswin/util/nc.exe'
alias qbasic='wine ~/progswin/util/qbasic.exe'
alias qe='wine ~/progswin/util/qe.exe'
alias tectri='wine ~/progswin/util/tectri.exe'
alias uedit='wine ~/progswin/util/uedit32.exe'

# pour utiliser libreoffice avec les commandes d'openoffice (plus aisées, surtout local<TAB>...):
alias oobase='lobase'
alias oocalc='localc'
alias oodraw='lodraw'
alias ooffice='loffice'
alias oofromtemplate='lofromtemplate'
alias ooimpress='loimpress'
alias oomath='lomath'
alias ooweb='loweb'
alias oowriter='lowriter'

# pour geler et dégeler les bloatouères classiques:
#alias gel_firefox_iceweasel='killall iceweasel -s 19'   #gel d'iceweasel
#alias degel_firefox_iceweasel='killall iceweasel -s 18' #dégel d'iceweasel
alias gel_firefox_iceweasel='killall firefox.* -r -s 19'   #gel de firefox => 2016_08_13__12_51_44: changement, firefox revient sous son nom dans debian.
alias degel_firefox_iceweasel='killall firefox.* -r -s 18' #dégel de firefox => 2016_08_13__12_51_44: changement, firefox revient sous son nom dans debian.
#alias gel_firefox_iceweasel='killall firefox -s 19'   #gel de firefox => 2016_08_16__22_02_02: ah, c'est firefox tout court, maintenant?
#alias degel_firefox_iceweasel='killall firefox -s 18' #dégel de firefox => 2016_08_16__22_02_02: ah, c'est firefox tout court, maintenant?
alias gel_thunderbird_icedove='killall icedove -s 19'   #gel d'icedove
alias degel_thunderbird_icedove='killall icedove -s 18' #dégel d'icedove
alias gel_chromium='killall chromium -s 19'             #gel de chromium
alias degel_chromium='killall chromium -s 18'           #dégel de chromium


# pour mettre un bon rythme au clavier:
xset r rate 200 100

#
# Set some generic aliases
#
#alias o='less -AS'	#-A marche pas sur le less de la debian
alias o='less -Si'
alias v='less -Si'   #pareil, mais le V est plus à main pour la gauche, avec la droite à la souris
alias ..='cd ..'
alias ...='cd ../..'
if test "$is" != "ksh" ; then
    alias -- +='pushd .'
    alias -- -='popd'
fi
alias rd=rmdir
alias md='mkdir -p'
alias which='type -p'
alias rehash='hash -r'
#alias you='su - -c "/sbin/yast2 online_update"'
if test "$is" != "ksh" ; then
    alias beep='echo -en "\007"' 
else
    alias beep='echo -en "\x07"'
fi
alias unmount='echo "Error: Try the command: umount" 1>&2; false'
alias mv='mv -i'

# "dog is better than cat" ne semble plus être dans les dépôts de Jessie; un succédanné:
alias dog=cat

export EDITOR=/usr/bin/vim
#export EDITOR=/usr/bin/mcedit

# For some news readers it makes sense to specify the NEWSSERVER variable here
#export NEWSSERVER=your.news.server

# If you want to use a Palm device with Linux, uncomment the two lines below.
# For some (older) Palm Pilots, you might need to set a lower baud rate
# e.g. 57600 or 38400; lowest is 9600 (very slow!)
#
#export PILOTPORT=/dev/ttyUSB1
export PILOTPORT=usb:
export PILOTRATE=115200

PATH=$PATH:$HOME/bin
export PATH

shopt -s histappend
PROMPT_COMMAND='history -a'

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

#BCPPLUS d'historique!! suivons le conseil démesuré de http://www.oreillynet.com/onlamp/blog/2007/01/whats_in_your_bash_history.html
export HISTFILESIZE=10000000000000
export HISTSIZE=10000000000
# encore plus de démesure...

# Compress the cd, ls -l series of commands.
alias lc="cl"
function cl () {
   if [ $# = 0 ]; then
      cd && ll
   else
      cd "$*" && ll
   fi
}
#plus simple:
#cl() { cd "$@" && l; }

#ls with color that doesn't scroll of the screen!
lsl () {
    ls --color=always -C $* | less -r
}

#pour ac3d
export AC3D_HOME=/home/pierre/progs_lin/ac3dlx/

######################
# Gestion des écrans #/*{{{*/
######################
#=> non, je mets tout ça dans des petits scripts dans ~/bin, plutôt.

## EcranLatitude Seul
#alias x_lat="xrandr --output eDP1 --mode 1366x768 --output VGA1 --off"
## EcranLatitude + autre écran:
##Config à la maison (ou du moins avec mon mathos):/*{{{*/
#
##alias x_lat_full="xrandr --output VGA1 --mode 1280x1024 --primary --output eDP1 --mode 1366x768 --pos 1280x424" #et là, l'écran du latitude est bien calé non solum à droite, sed etiam en bas de l'écran VGA.
#alias x_lat_full=" xrandr --output VGA1 --mode 1600x1200 --primary --output LVDS1 --mode 1366x768 --pos 1600x400" # encore mieux, résolution plus haute de l'écran cathodique
#alias x_lat_full="xrandr --output VGA1 --mode 1600x1200 --primary --output eDP1 --mode 1366x768 --pos 1600x600" # encore mieux, résolution plus haute de l'écran cathodique
#
##alias x_lat_full_reinit="xrandr --newmode "1280x1024" 108.88  1280 1360 1496 1712  1024 1025 1028 1060 +HSync +Vsync && xrandr --addmode VGA1 1280x1024 && x_lat_full"
##alias x_lat_full_reprise="xrandr --addmode VGA1 1280x1024 && x_lat_full" #pour la reprise (...)
##/*}}}*/
#
#
#
## EcranWind Seul
alias x_wind="xrandr --output LVDS1 --mode 1024x600 --output VGA1 --off"
## EcranWind + autre écran:
##Config à la maison (ou du moins avec mon mathos):/*{{{*/
#
## EcranWind + Ecran LCD de durandeux, sur planche casto à MrBed à Olivet
#alias x_full_mrbed="xrandr --output VGA1 --mode    1440x900     --output LVDS1 --mode 1024x600 --primary --pos 0x424 --right-of VGA1"
#
## EcranVGA Seul
##alias x_vga="xrandr --output LVDS1 --off --output VGA1 --mode 1280x800"                                                 #marche plus après passage lenny-squeeze
#alias x_vga="xrandr --output LVDS1 --off --output VGA1 --mode 1360x768"
# alias x_vga="xrandr --output LVDS1 --off --output VGA1 --mode 1280x1024"
#alias x_vga_failsafe="xrandr --output LVDS1 --off --output VGA1 --mode 800x600"
##alias x_vga_tv="xrandr --output LVDS1 --off --output VGA1 --mode 1440x900"
#
#
## EcranWind + EcranVGA
##alias x_full="xrandr --output LVDS --mode 1024x600 --pos 0x424 --output VGA --mode 1280x800" # --pos 1024x0"
##alias x_full="xrandr --output LVDS --mode 1024x600 --pos 0x424 --output VGA --mode 1280x800 --left-of LVDS"	         # => marche pas avec l'accélération 3D: "xrandr: screen cannot be larger than 2048x2048 (desired size 2304x800)"
##alias x_full="xrandr --output LVDS1 --mode 640x480  --pos 0x424 --output VGA1 --mode 1280x800 --left-of LVDS1"          #marche plus après passage lenny-squeeze
#
##pour avoir une bonne résolution sur l'écran d'autan et avoir l'accélération 3D, on met en vertical:
##alias x_fullvertical="xrandr --output LVDS1 --mode 1024x600 --pos 0x424 --output VGA1 --mode 1280x800 --above LVDS1"      #marche plus après passage lenny-squeeze
#alias x_fullvertical="xrandr --output LVDS1 --mode 1024x600 --pos 0x424 --output VGA1 --mode 1360x768 --above LVDS1"
##xrandr --output LVDS --mode 1024x600 --pos 0x424 --output VGA --mode 1280x800 --below LVDS
##alias x_full="xrandr --output LVDS1 --mode 1024x600 --pos 0x424 --output VGA1 --mode 1360x768 --left-of LVDS1"             #marche, avec l'accélération 3D, après passage lenny-squeeze!
##alias x_full="xrandr --output VGA1 --mode 1360x768 --primary --output LVDS1 --mode 1024x600 --pos 0x424 --right-of VGA1"   #en inversant les 2 écrans, pour toujours garder celui du wind en principal => moui, bof => adopté longtemps
##alias x_full="xrandr --output VGA1 --mode 1280x1024 --primary --output LVDS1 --mode 1024x600 --pos 0x424 --right-of VGA1"  #en inversant les 2 écrans, pour toujours garder celui du wind en principal => moui, bof => le même, mais avec l'écran artisanat_français
##alias x_full="xrandr --output VGA1 --mode 1280x1024 --primary --output LVDS1 --mode 1024x600 --pos 0x424 --right-of VGA1"  #=> ouille, marche plus après passage de squeeze en stable: ?
##alias x_full="xrandr --newmode "1280x1024" 108.88  1280 1360 1496 1712  1024 1025 1028 1060 +HSync +Vsync && xrandr --addmode VGA1 1280x1024 && xrandr --output VGA1 --mode 1280x1024 --primary --output LVDS1 --mode 1024x600 --pos 0x424 --right-of VGA1" #voilà, comme ça, ça marche; presque: pas à la reprise...
##alias x_full="xrandr --newmode "1280x1024" 108.88  1280 1360 1496 1712  1024 1025 1028 1060 +HSync +Vsync && xrandr --addmode VGA1 1280x1024 && xrandr --output VGA1 --mode 1280x1024 --primary --output LVDS1 --mode 1024x600 --pos 0x424 --right-of VGA1" #voilà, comme ça, ça marche; presque: pas à la reprise...
#
#
#alias x_full="xrandr --output VGA1 --mode 1280x1024 --primary --output LVDS1 --mode 1024x600 --pos 1280x424" #et là, l'écran du wind est bien calé non solum à droite, sed etiam en bas de l'écran VGA.
#alias x_full="xrandr --output VGA1 --mode 1024x768  --output LVDS1 --mode 1024x600 --pos 1440x500 --primary" #merdalors, avec autan re-installé, pas moyen d'aller mieux en résolution... <= non, ça remarche, après avoir refait un xorg.conf, le 2015_02_05__17_35_35 
#alias x_full="xrandr --output VGA1 --mode 1280x1024 --primary --output LVDS1 --mode 1024x600 --pos 1280x424" #et là, l'écran du wind est bien calé non solum à droite, sed etiam en bas de l'écran VGA.
#alias x_full="xrandr --output VGA1 --mode 1280x1024 --output LVDS1 --mode 1024x600 --pos 1280x424 --primary" #Idem, mais avec l'écran du wind en primaire. C'est un peu mieux.
alias x_full="xrandr --output VGA1 --mode 1280x1024 --above LVDS1 --output LVDS1 --mode 1024x600 --primary" #Idem, mais avec l'écran cathodique au-dessus; une autre configuration à Mesté.
alias x_full_reinit="xrandr --newmode "1280x1024" 108.88  1280 1360 1496 1712  1024 1025 1028 1060 +HSync +Vsync && xrandr --addmode VGA1 1280x1024 && x_full"
##alias x_full_reinit="xrandr --addmode VGA1 1280x1024 && x_full"
##alias x_full_reprise="xrandr --addmode VGA1 1280x1024 && xrandr --output VGA1 --mode 1280x1024 --primary --output LVDS1 --mode 1024x600 --pos 0x424 --right-of VGA1" #pour la reprise (...)
#alias x_full_reprise="xrandr --addmode VGA1 1280x1024 && x_full" #pour la reprise (...)
#
##/*}}}*/
##Ity:/*{{{*/
## EcranWind + EcranVGA à Ity, écran recommandant 1440x900 60Hz
###alias x_full_ity="xrandr --output LVDS --mode 640x480  --pos 0x424 --output VGA --mode 1440x900 --left-of LVDS" #non, trop large
##alias x_full_ity="xrandr --output LVDS1 --mode 640x480  --pos 0x424 --output VGA1 --mode 1280x800 --left-of LVDS1"
##alias x_full_ityvertical="xrandr --output LVDS1 --mode 1024x600 --pos 0x424 --output VGA1 --mode 1440x900 --above LVDS1"
## EcranVGA à Ity, écran recommandant 1440x900 60Hz
##alias x_vga_ity="xrandr --output LVDS1 --off --output VGA1 --mode 1440x900"
##alias x_full_ity='xrandr --output LVDS1 --mode 1024x600  --primary --output VGA1  --mode 1600x1200 --right-of LVDS1'
##alias x_full_ity='xrandr --output LVDS1 --mode 1024x600  --output VGA1  --mode 1600x1200 --right-of LVDS1 --primary'
## EcranVGA à Ity, écran pas mal à 1920x1440
##alias x_full_ity='xrandr --output VGA1  --mode 1920x1440 --right-of LVDS1 --output LVDS1 --mode 1024x600  --primary'
##alias x_full_ity='xrandr --output VGA1  --mode 1600x900  --right-of LVDS1 --output LVDS1 --mode 1024x600  --primary'
##alias x_full_ity='xrandr --output VGA1  --mode 1600x900  --right-of LVDS1 --primary --output LVDS1 --mode 1024x600'
##alias x_full_ity='xrandr --output VGA1 --mode 1920x1200  --left-of LVDS1 --primary --output LVDS1 --mode 1024x600'
##alias x_full_ity='xrandr --output VGA1 --mode 1920x1200 --primary --output LVDS1 --mode 1024x600 --pos 1920x600'
##alias x_full_ity='xrandr --output VGA1 --mode 1920x1200 --primary --output LVDS1 --mode 1024x600 --pos -1920x600'
#alias x_full_ity='xrandr --output VGA1 --mode 1920x1200 --primary --output LVDS1 --mode 1024x600 --pos -1024x600'
##/*}}}*/
##Hassaï:{{{
## EcranWind + EcranVGA à AMC
#alias x_full_amc="xrandr --output LVDS1 --mode 1024x600 --pos 0x424 --output VGA1 --mode 1024x768 --left-of LVDS1"
##}}}
##Siribaya:{{{
## EcranWind + EcranVGA à Siribaya
#alias x_full_siribaya="xrandr --output LVDS1 --mode 1024x600 --pos 0x424 --output VGA1 --mode 1600x900 --right-of LVDS1"
##}}}
##St-Etienne:{{{
## EcranWind + vidéoprojecteur à St-Etienne
#alias x_full_st_etienne="xrandr --output VGA1 --mode 1400x1050 --output LVDS1 --mode 1024x600 --pos 0x424 --below VGA1 --primary"
##}}}
##Hinda:{{{
#alias x_full_hinda="xrandr --output VGA1 --mode 1024x768 --output LVDS1 --mode 1024x600 --pos 0x424 --left-of VGA1 --primary"
##}}}
##Espérance:{{{
#alias x_full_esperance="xrandr --output VGA1 --mode 1440x900 --primary --output LVDS1 --mode 1024x600 --pos 1440x500"
##}}}
##Roanne:{{{
#alias x_full_roanne="xrandr --output VGA1 --mode 1600x1200 --primary --output LVDS1 --mode 1024x600 --pos -1024x1000"
##}}}
##IMSRN:{{{
#alias x_full_imsrn_pole_roche="xrandr --output VGA1 --primary --mode 1280x1024 --output LVDS1 --mode 1024x600 --pos -1024x700" #et là, l'écran du wind est bien calé non solum à gauche, sed etiam en bas de l'écran VGA.
##alias x_full_imsrn="xrandr --output VGA1 --mode 1600x1200 --primary --output LVDS1 --mode 1024x600 --pos -1024x1000" #essayer
#alias x_full_imsrn_pole_sol="xrandr --output VGA1 --mode 1920x1080 --primary --output LVDS1 --mode 1024x600 --below VGA1"
#alias x_full_imsrn_millau="xrandr --output VGA1 --mode 1280x1024 --primary --output LVDS1 --mode 1024x600 --below VGA1"
##}}}
##/*}}}*/


# pour avoir un séparateur décimal . au lieu de ,
export LC_NUMERIC=C

# pour avoir un meilleur psql avec less
export PAGER=less
export LESS="-iMSx4 -R"
#export LESS=-RSFX


# pour avoir readline avec psql 
# (ça y était avant, mais ça a mystérieusementdisparu, en mars 2011):
#alias psql="LD_PRELOAD=/lib/libreadline.so.5 psql"
# Ah, ça ne fonctionne plus, en 2016. On dirait qu'il n'y en a pas besoin, même.


export PYTHONSTARTUP='.pythonstartup.py'

# Je me fais un prompt qui permette de copier-coller sans avoir à retrafiquer:
#PS1="  # \u@\h: \w        < $(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g') >\n"
PS1="\n  # \u@\h: \w        < $(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g') >\n"
#PS1="\n  # \u@\h: \w$        < $(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g') >\n"
#PS1="\n   \u@\h:\w$        < $(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g') >\n"



####  GeolLLibre variables: ####
## Trié comme ça, bêtement, c'est la dernière valeur qui est choisie.
## Con mais bon.
export GLL_BD_HOST=duran
export GLL_BD_HOST=latitude
export GLL_BD_HOST=autan
export GLL_BD_HOST=localhost
export GLL_BD_HOST=black-pearl
export POSTGEOL=postgeol
export GLL_BD_NAME=bdexplo
export GLL_BD_NAME=$POSTGEOL
export GLL_BD_PORT=5432
export GLL_BD_USER=$USER
export GLL_BD_USER=pic # trigramme de chez Sémofi.
################################

export CONNINFO="-h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER $POSTGEOL"

export BROWSER=firefox

alias htop='htop -d 50'
alias htopbg='htop -d 600'
alias px='ps faux | grep -v "grep faux" | grep -i -e VSZ -e'
#alias px='ps auxf | grep -v grep | grep -i -e VSZ -e'
alias dus='du -ch | sort -h'
alias dua='du -ach | sort -h'
alias findhere='find . -iname'
alias cloudcommander_semopi_blackpearl='firefox http://black-pearl.local:8000'
