########################################################################################
########        GeolLLibre variables:                                           ########
## Trié comme ça, bêtement, c'est la dernière valeur qui est choisie.
## Con mais bon.
## Un paragraphe par variable, dernière ligne valide.
## Et une ligne #ée, pour n'avoir qu'un paragraphe. Commode.

export POSTGEOL=bdexplo
export POSTGEOL=postgeol

export GLL_BD_HOST=duran
export GLL_BD_HOST=black-pearl
export GLL_BD_HOST=geopoppy
export GLL_BD_HOST=autan
export GLL_BD_HOST=localhost
export GLL_BD_HOST=semopi
export GLL_BD_HOST=geolllibre.org
export GLL_BD_HOST=latitude

export GLL_BD_USER=pic # trigramme de chez Sémofi.
export GLL_BD_USER=$USER

export GLL_BD_NAME=bdexplo
export GLL_BD_NAME=$POSTGEOL

export GLL_BD_PORT=5432

# Agrégation de ces variables dans une variable de connexion:
export CONNINFO_GLL="-h $GLL_BD_HOST -p $GLL_BD_PORT -U $GLL_BD_USER $POSTGEOL"
########################################################################################


########################################################################################
########        PAR variables:                                                  ########
export PAR=par_02 # anciennement; ça a changé, pour Pellehaut:
export PAR=par_viti

export PAR_BD_HOST=geolllibre.org
export PAR_BD_HOST=pellehovh
export PAR_BD_HOST=latitude

export PAR_BD_USER=$USER

export PAR_BD_NAME=bdexplo
export PAR_BD_NAME=$PAR

export PAR_BD_PORT=5432

# Agrégation de ces variables dans une variable de connexion:
export CONNINFO_PAR="-h $PAR_BD_HOST -p $PAR_BD_PORT -U $PAR_BD_USER $PAR_BD_NAME"
########################################################################################

########################################################################################
########        Une définition pour une autre base                              ########
export BD_HOST=latitude
export BD_USER=$USER
export BD_NAME=malemort
export BD_PORT=5432
# Agrégation de ces variables dans une variable de connexion:
export CONNINFO_MALEM="-h $BD_HOST -p $BD_PORT -U $BD_USER $BD_NAME"
########################################################################################


########################################################################################
########        Une définition pour ma base sur latitude, pour tests            ########
export BD_HOST=latitude
export BD_USER=$USER
export BD_NAME=pierre
export BD_PORT=5432
# Agrégation de ces variables dans une variable de connexion:
export CONNINFO_PIERRE="-h $BD_HOST -p $BD_PORT -U $BD_USER $BD_NAME"
########################################################################################


export CONNINFO=$CONNINFO_PAR   # ATTENTION!!! définition de CONNINFO_PAR     par défaut
export CONNINFO=$CONNINFO_MALEM # ATTENTION!!! définition de CONNINFO_MALEM   par défaut
export CONNINFO=$CONNINFO_PIERRE # ATTENTION!!! définition de CONNINFO_PIERRE par défaut
export CONNINFO=$CONNINFO_GLL   # ATTENTION!!! définition de CONNINFO_GLL     par défaut

# export GLL_BD_USER=$PAR_BD_USER
# export GLL_BD_PORT=$PAR_BD_PORT
# export GLL_BD_HOST=$PAR_BD_HOST
# export GLL_BD_NAME=$PAR_BD_NAME
########################################################################################
########################################################################################





# export TERM=xterm

if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi

# Des alias de ls comme s'il en pleuvait:
alias ls='ls --color=auto'
alias ll='ls -lh'
alias dir='ll'
alias la='ll -a'
alias l='ls -alFh'
alias ls-l='ls -l'
alias lll='ls -trlh | less'
alias lla='ll -a | less'
alias lls='ls -trlh | tail -10'
alias llsa='ls -trlha | tail -10'
alias llls='ls -trlh | tail -50'
alias lllsa='ls -trlha | tail -50'
alias lllls='ls -trlh | tail -100'
alias llllsa='ls -trlha | tail -100'

# Un ls "vivant":
alias ls_vivant='watch -d -n 0.2 "pwd; echo ""; ls -tl"'
alias ls_vivant_fich_cach='watch -d -n 0.2 "pwd; echo ""; ls -tla"'
alias lv='ls_vivant'
alias lva='ls_vivant_fich_cach'


# Pour travailler sur le dernier fichier:
#alias der_fichier='(ls --group-directories-first -Htr | tail -1)'
# export der_fichier=`ls --group-directories-first -Htr | tail -1`
# alias der_fichier=`ls --group-directories-first -Htr | tail -1`
function der_fichier() {
  echo $(ls --group-directories-first -Ht | head -1)
  # Tentatives de mieux faire (vaines):{{{
	#   echo $(
	#     find . -maxdepth 1 -type f -exec ls -1 {}\;
	#     \ --group-directories-first\ -Htr\ '{}'\ \;
	#      | tail -1)
	# }}}
}
alias edit_der_fichier="f=\$(der_fichier); $EDITOR \$f"
alias vi_der_fichier=edit_der_fichier



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
# alias nc='wine ~/progswin/util/nc.exe'
alias qbasic='wine ~/progswin/util/qbasic.exe'
alias qe='wine ~/progswin/util/qe.exe'
alias tectri='wine ~/progswin/util/tectri.exe'
alias uedit='wine ~/progswin/util/uedit32.exe'
alias freemind='cd ~/progs_lin/freemind/ && sh freemind.sh'

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
alias gel_firefox_iceweasel='killall firefox* -r -s 19'   #gel de firefox => 2016_08_13__12_51_44: changement, firefox revient sous son nom dans debian.
alias degel_firefox_iceweasel='killall firefox* -r -s 18' #dégel de firefox => 2016_08_13__12_51_44: changement, firefox revient sous son nom dans debian.
#alias gel_firefox_iceweasel='killall firefox -s 19'   #gel de firefox => 2016_08_16__22_02_02: ah, c'est firefox tout court, maintenant?
#alias degel_firefox_iceweasel='killall firefox -s 18' #dégel de firefox => 2016_08_16__22_02_02: ah, c'est firefox tout court, maintenant?
#alias gel_thunderbird_icedove='killall icedove -s 19'   #gel d'icedove
alias gel_thunderbird_icedove='killall thunderbird -s 19'   #gel de thunderbird
#alias degel_thunderbird_icedove='killall icedove -s 18' #dégel d'icedove
alias degel_thunderbird_icedove='killall thunderbird -s 18' #dégel de thunderbird
alias gel_chromium='killall chromium -s 19'             #gel de chromium
alias degel_chromium='killall chromium -s 18'           #dégel de chromium


# pour mettre un bon rythme au clavier (si on est dans un terminal X):
#[ ! -t 0 ] && xset r rate 200 100
[[ $DISPLAY ]]&& xset r rate 200 100


#
# Set some generic aliases
#
#alias o='less -AS'	#-A marche pas sur le less de la debian
alias o='less -SiN'
alias v='less -SiNX'   #pareil, mais le V est plus à main pour la gauche, avec la droite à la souris; “less -X” if your screen clears when you quit less and you want to avoid that.

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

# Trouvé sur touïteur:
alias busy='my_file=$(find /usr/include -type f | sort -R | head -n 1); my_len=$(wc -l $my_file | cut -d " " -f 1); let "r = $RANDOM % $my_len" 2>/dev/null; vim +$r $my_file'
# Une version perso de cet alias rigolo pour paraître occupé...
alias oqp='fontchiers=$(find ~/dev/ -maxdepth 3 -type f | 'grep' "\.py$\|\.r$\|\.sh$" | sort -R | head -n 5); cmd="vim -o "; for f in $fontchiers; do len=$(wc -l $f | cut -d " " -f 1); let "r = $RANDOM % $len" 2>/dev/null; cmd+=" $f +$r "; done; echo $cmd; $cmd'


export EDITOR=/usr/bin/vim
#export EDITOR=/bin/nano
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


if [[ "$(whoami)" == "root" ]] ; then
	PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin:$HOME/bin
	echo "Je suis en route!"
else
	PATH=$PATH:$HOME/bin
	PATH=$PATH:$HOME/.local/bin
fi
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
# https://linuxconfig.org/how-to-manage-bash-history => If we want to avoid duplicates in the whole shell history no matter the position they have, we can use the erasedups value, instead.
export HISTCONTROL=ignoreboth:erasedups
#BCPPLUS d'historique!! suivons le conseil démesuré de http://www.oreillynet.com/onlamp/blog/2007/01/whats_in_your_bash_history.html
export HISTFILESIZE=1000000000000000
export HISTSIZE=1000000000000
# encore plus de démesure...

# Compress the cd, ls -l series of commands.
alias lc="cl"
function cl () {
   if [ $# = 0 ]; then
      cd      && ls -trlh | tail
   else
      cd "$*" && ls -trlh | tail
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
# Gestion des écrans #
######################
#=> non, je mets tout ça dans des petits scripts dans ~/bin, plutôt.

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

# Prompt PS1:{{{
# Je me fais un prompt qui permette de copier-coller sans avoir à retrafiquer:
# Des vieilleries:{{{
# PS1="  # \u@\h: \w        < $(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g') >\n"
# PS1="\n  # \u@\h: \w$        < $(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g') >\n"
# PS1="\n   \u@\h:\w$        < $(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g') >\n"
# PS1="\n  # \u@\h: \w        < $(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g') >\n"
# # Ah, enfin ce que je cherchais depuis longtemps: l'heure courante:
# PS1='\t \[\033[0;31m]\u\033[0m]'
# PS1="\n  # \u@\h: \w        < \D{%Y_%m_%d__%T} >\n"
# # Allez, un peu de couleur, pour égayer:
# PS1="\n  \033[0;32m# \u@\h: \033[0m\w        < \D{%Y_%m_%d__%T} >\n"
# # Et puis aussi le PID, manière d'avoir un identifiant unique par xterm
# #(pratique, quand on en arrive là: {{{
# #  # pierre@latitude: ~        < 2019_10_07__12:03:54 >
# #px bash | wc -l
# #75
# #}}}
# PS1="\n  \033[0;32m# \u@\h: \033[0m\w        < \D{%Y_%m_%d__%T} >  [bashpid_$BASHPID]\n"
# Je tente d'ôter le \n avant le prompt, manière de rendre plus compacts et monolithiques mes copié-collés depuis des terminaux:
# PS1="  \033[0;32m# \u@\h: \033[0m\w        < \D{%Y_%m_%d__%T} >  [bashpid_$BASHPID]\n"
# Ah, aussi, j'y ajoute la branche, si je suis dans un répertoire gitteux:
# PS1="  \033[0;32m# \u@\h: \033[0m\w $(__git_ps1)        < \D{%Y_%m_%d__%T} >  [bashpid_$BASHPID]\n"
#export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;33m\]$(__git_ps1)\[\033[01;34m\] \$\[\033[00m\] '
# Et puis aussi les états dirty, untracked, stash, etc.:
# export GIT_PS1_SHOWDIRTYSTATE=1
# export GIT_PS1_SHOWCOLORHINTS=1
# export GIT_PS1_SHOWUNTRACKEDFILES=1
#PS1=" \033[0;32m# \u@\h: \033[0m\w $(__git_ps1)  < \D{%Y_%m_%d__%T} >  [bashpid_$BASHPID]\n"

# => ces fioritures avec du git ne fonctionnent correctement que quand on démarre un bash dans un répertoire git, pas sinon.
# 2020_11_02__09_19_28 j'ajoute juste une ligne pour l'état du git, à partir du prompt précédent:
# PS1=" \033[0;32m# \u@\h: \033[0m\w < \D{%Y_%m_%d__%T} > [bashpid_$BASHPID \#]"
# PS1="\n \033[0;32m\]# \u@\h: \033[0m\]\w < \D{%Y_%m_%d__%T} > [bashpid_$BASHPID\033[01;34m\] \#\033[0m\]]"
# }}}

# Annexe: doc pour mettre des couleurs:{{{
#
# To add colors to the shell prompt use the following export command syntax:
# '\e[x;ym $PS1 \e[m'
# Where,
#    \e[ : Start color scheme.
#    x;y : Color pair to use (x;y)
#    $PS1 : Your shell prompt variable.
#    \e[m : Stop color scheme.
# 
# export PS1="\e[0;31m[\u@\h \W]\$ \e[m "
#
# A list of color codes
# Color     Code
# Black     0;30
# Blue      0;34
# Green     0;32
# Cyan      0;36
# Red       0;31
# Purple    0;35
# Brown     0;33
# Blue      0;34
# Green     0;32
# Cyan      0;36
# Red       0;31
# Purple    0;35
# Brown     0;33
#
# Des variables, allez:
colour_txtblk='\e[0;30m' # Black - Regular
colour_txtred='\e[0;31m' # Red
colour_txtgrn='\e[0;32m' # Green
colour_txtylw='\e[0;33m' # Yellow
colour_txtblu='\e[0;34m' # Blue
colour_txtpur='\e[0;35m' # Purple
colour_txtcyn='\e[0;36m' # Cyan
colour_txtwht='\e[0;37m' # White
colour_bldblk='\e[1;30m' # Black - Bold
colour_bldred='\e[1;31m' # Red
colour_bldgrn='\e[1;32m' # Green
colour_bldylw='\e[1;33m' # Yellow
colour_bldblu='\e[1;34m' # Blue
colour_bldpur='\e[1;35m' # Purple
colour_bldcyn='\e[1;36m' # Cyan
colour_bldwht='\e[1;37m' # White
colour_unkblk='\e[4;30m' # Black - Underline
colour_undred='\e[4;31m' # Red
colour_undgrn='\e[4;32m' # Green
colour_undylw='\e[4;33m' # Yellow
colour_undblu='\e[4;34m' # Blue
colour_undpur='\e[4;35m' # Purple
colour_undcyn='\e[4;36m' # Cyan
colour_undwht='\e[4;37m' # White
colour_bakblk='\e[40m'   # Black - Background
colour_bakred='\e[41m'   # Red
colour_bakgrn='\e[42m'   # Green
colour_bakylw='\e[43m'   # Yellow
colour_bakblu='\e[44m'   # Blue
colour_bakpur='\e[45m'   # Purple
colour_bakcyn='\e[46m'   # Cyan
colour_bakwht='\e[47m'   # White
colour_txtrst='\e[0m'    # Text Reset

# }}}

# Je redécoupe la construction du PS1:{{{
# - une ligne vide d'abord, pour espacer, et une espace pour ne pas que ça arrive dans un historique:
PS1="\n "
# - l'utilisateur, avec une couleur rouge ou verte, selon qu'il soit root ou pas, avec un # pour innocenter la ligne de prompt:
if [[ "$(whoami)" == "root" ]] ; then
  PS1+="$colour_bldred# \u@"
else
  PS1+="$colour_txtgrn# \u@"
fi
# - le nom d'hôte:
PS1+="\h"
# - changer le prompt si on est dans un chroot:
# if [ "$(stat -c %d:%i / 2> /dev/null)" != "$(stat -c %d:%i /proc/1/root/. 2> /dev/null)" ]; then
# if [[ $(awk 'BEGIN{exit_code=1} $2 == "/" {exit_code=0} END{exit exit_code}' /proc/mounts) ]]; then
# if [[ "$(ls -di / )" != "2" ]]; then 
# if [[ "$(ls -di / | cut -f 1 )" != "2" ]] ; then
if [[ "$(ls -di / | cut -d ' ' -f 1 )" != "2" ]]; then
  # echo "We are chrooted!"
  PS1+="{#CHROOT#}$colour_txtrst"
else
  # echo "Business as usual"
  PS1+="$colour_txtrst"
fi
# - le répertoire courant:
PS1+=": \w"
# - l'horodatage:
PS1+=" < $colour_txtpur\D{%Y_%m_%d__%H_%M_%S}$colour_txtrst > [bashpid_$BASHPID$colour_bldblu \#$colour_txtrst]"
# - et plein de git:
#PS1+='$(if git rev-parse --git-dir > /dev/null 2>&1; then echo " \[\033h[38;5;63m\]["; fi)\[\033[38;5;202m\]'
#PS1+='$(if git rev-parse --git-dir > /dev/null 2>&1; then echo " \e[\033[38;5;63m\]["; fi)\[\033[38;5;202m\]$(git branch 2>/dev/null | grep "^*" | colrm 1 2)\[\033[38;5;63m\]$(if git rev-parse --git-dir > /dev/null 2>&1; then echo "]"; fi)'
# PS1+='$(if git rev-parse --git-dir > /dev/null 2>&1; then echo " \e[0;31m\]["; fi)\[\033[38;5;202m\]$(git branch 2>/dev/null | grep "^*" | colrm 1 2)\[\033[38;5;63m\]$(if git rev-parse --git-dir > /dev/null 2>&1; then echo "]"; fi)'
# PS1="\n \033[0;32m\]# \u@\h: \033[0m\]\w < \D{%Y_%m_%d__%H_%M_%S} > [bashpid_$BASHPID\033[01;34m\] \#\033[0m\]]"
#PS1+='\[\033[38;5;63m\]'
#PS1+='$(if git rev-parse --git-dir > /dev/null 2>&1; then echo " \[\033h[38;5;63m\]["; fi)\[\033[38;5;202m\]'
# PS1+='$(if git rev-parse --git-dir > /dev/null 2>&1; then echo " \e[\033[38;5;63m\]["; fi)\[\033[38;5;202m\]$(git branch 2>/dev/null | grep "^*" | colrm 1 2)\[\033[38;5;63m\]$(if git rev-parse --git-dir > /dev/null 2>&1; then echo "]"; fi)'
# PS1+='$(if git rev-parse --git-dir > /dev/null 2>&1; then echo -e \" [$colour_bldred\"; fi)\[\e[38;5;202m\]$(git branch 2>/dev/null | grep \"^*\" | colrm 1 2)\[\e[38;5;63m\]$(if git rev-parse --git-dir > /dev/null 2>&1; then echo \"]\"; fi)'

# 2023_08_16__17_26_09 
# => ça n'écrit plus quelque chose de chouette:
#  # pierre@latitude: ~/config < 2023_08_16__17_25_51 > [bashpid_26083 49] [;31m* master]
# => autre solution:
source ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM=1
export GIT_PS1_SHOWUPSTREAM="auto verbose name"
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_COMPRESSSPARSESTATE=1
export GIT_PS1_SHOWCONFLICTSTATE="yes"
# PS1='[\u@\h \W$(__git_ps1 " (%s)")]\$ '
PS1+='$(__git_ps1 " (%s)")'
# -on revient au noir et on passe à la ligne, finaloumen:
PS1+="$colour_txtrst\n"
# }}}


# }}}


export BROWSER=firefox

alias htop='htop -d 50'
alias htopbg='htop -d 600'
# alias px='ps auxf | grep -v grep | grep -i -e VSZ -e'
# alias px='ps faux | grep -v "grep faux" | grep -i -e VSZ -e'
alias px='ps faux | 'grep' -v "'grep' faux" | 'grep' -vi -e VSZ | grep -e'
alias dus='du -ch | sort -h'
alias dua='du -ach | sort -h'
alias findhere='find . -iname'
alias cloudcommander_semopi_blackpearl='firefox http://black-pearl.local:8000'

# Pour pouvoir utiliser Ctrl-S pour sauver dans un vim, sans que le terminal ne s'arrête bêtement:
bind -r '\C-s'
#stty -ixon
stty ixoff -ixon

# Pour faire tourner gtkcam
export RED_GTK_CAMERA=YES
export GST_V4L2_USE_LIBV4L2=1


# Pour ekylibre, cf. https://github.com/ekylibre/ekylibre/wiki/Base-ubuntu-20-04 {{{
# 2022_05_10__15_37_19 ça ralentit notablement mon démarrage de bash; je mets ça dans une condition si on est dans un répertoire où il y a kylibre:
re='.*kylib.*'
if [[ $(pwd) =~ $re ]]; then 
	export PATH="$HOME/.rbenv/bin:$PATH"
	eval "$(rbenv init -)"

	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
	export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
fi
# }}}

# Pour avoir les gems installés par gem install --user-install dans mon $PATH:
# export PATH="$PATH:$HOME/.gem/ruby/2.7.0/bin"
# export GEM_HOME=$HOME/.gem
# export GEM_PATH=$HOME/.gem



# Pour le MOOC de bash:{{{
alias mooc_bash_document_compagnon="evince mooc_bash/MSB_doc_compagnon.pdf &"

# # Exercices lors du MOOC bash:
# D=$HOME/cv
# export D

# shellcheck shell=sh
#}}}


# Expand $PATH to include the directory where snappy applications go.
snap_bin_path="/snap/bin"
if [ -n "${PATH##*${snap_bin_path}}" -a -n "${PATH##*${snap_bin_path}:*}" ]; then
    export PATH=$PATH:${snap_bin_path}
fi

# Ensure base distro defaults xdg path are set if nothing filed up some
# defaults yet.
if [ -z "$XDG_DATA_DIRS" ]; then
    export XDG_DATA_DIRS="/usr/local/share:/usr/share"
fi

# Desktop files (used by desktop environments within both X11 and Wayland) are
# looked for in XDG_DATA_DIRS; make sure it includes the relevant directory for
# snappy applications' desktop files.
snap_xdg_path="/var/lib/snapd/desktop"
if [ -n "${XDG_DATA_DIRS##*${snap_xdg_path}}" -a -n "${XDG_DATA_DIRS##*${snap_xdg_path}:*}" ]; then
    export XDG_DATA_DIRS="${XDG_DATA_DIRS}:${snap_xdg_path}"
fi




# Tiré de: https://linuxhandbook.com/linux-alias-command/ :
#Displaying iptables information the easy way :)
alias iptlist='/sbin/iptables -L -n -v --line-numbers'           #this will display all lines of your current iptables
alias iptlistin='/sbin/iptables -L INPUT -n -v --line-numbers'   #this will display all your INCOMING rules in iptables
alias iptlistout='/sbin/iptables -L OUTPUT -n -v --line-numbers' #this will display all your OUTGOING rules in iptables

#make rm command safer
alias rm="rm -i" 

# Des couleurs!
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -lrt'
alias ls='ls --color=auto'




# Inspiration de https://opensource.com/article/19/7/bash-aliases :

# Find a command in your grep history
alias history_grep='history | grep'


# # Create a Python virtual environment
# Do you code in Python?
# Do you code in Python a lot?
# If you do, then you know that creating a Python virtual environment requires, at the very least, 53 keystrokes.
# That’s 49 too many, but that’s easily circumvented with two new aliases called ve and va:
alias ve='python3 -m venv ./venv'
alias va='source ./venv/bin/activate'
# Running ve creates a new directory, called venv, containing the usual virtual environment filesystem for Python3. The va alias activates the environment in your current shell:
# $ cd my-project
# $ ve 
# $ va
# (venv) $ 


# # Add a copy progress bar
# Everybody pokes fun at progress bars because they’re infamously inaccurate. And yet, deep down, we all seem to want them. The UNIX cp command has no progress bar, but it does have a -v option for verbosity, meaning that it echoes the name of each file being copied to your terminal. That’s a pretty good hack, but it doesn’t work so well when you’re copying one big file and want some indication of how much of the file has yet to be transferred.
# The pv command provides a progress bar during copy, but it’s not common as a default application. On the other hand, the rsync command is included in the default installation of nearly every POSIX system available, and it’s widely recognized as one of the smartest ways to copy files both remotely and locally.
# Better yet, it has a built-in progress bar.
alias cpv='rsync -ah --info=progress2'
# Using this alias is the same as using the cp command:
# $ cpv bigfile.flac /run/media/seth/audio/
#           3.83M 6%  213.15MB/s    0:00:00 (xfr#4, to-chk=0/4)
# An interesting side effect of using this command is that rsync copies both files and directories without the -r flag that cp would otherwise require.



# # Protect yourself from file removal accidents
# You shouldn’t use the rm command. The rm manual even says so:
#     Warning: If you use ‘rm’ to remove a file, it is usually possible to recover the contents of that file. If you want more assurance that the contents are truly unrecoverable, consider using ‘shred’.
# If you want to remove a file, you should move the file to your Trash, just as you do when using a desktop.
# POSIX makes this easy, because the Trash is an accessible, actual location in your filesystem. That location may change, depending on your platform: On a FreeDesktop, the Trash is located at ~/.local/share/Trash, while on MacOS it’s ~/.Trash, but either way, it’s just a directory into which you place files that you want out of sight until you’re ready to erase them forever.
# This simple alias provides a way to toss files into the Trash bin from your terminal:
alias tcn='mv --force -t ~/.local/share/Trash '
# Je refais ça avec une fonction:
function rm_trash() {
  # Définissons la poubelle (je crois que c'est un peu POSIX):
  trash="$HOME/.local/share/Trash"
  # Faisons un répertoire par jour de suppression dans cette poubelle:
  # trash_of_ze_day="$trash/$(date +%Y_%m_%d | sed -e 's/\:/_/g')"
  trash_of_ze_day="$trash/$(date +%Y_%m_%d)"
  mkdir -p "$trash_of_ze_day"
  target_file=$(basename "$1")
  # Si jamais il y a déja un féchier du nom de $1, on y rajoute autant de _ au c.l que nécessaire
  while [[ -e $trash_of_ze_day/$target_file ]]; do
    target_file+="_"
  done
  # Enfin, on met tout ça à la poubelle triée:
  # mv --force -t "$1" "$trash_of_ze_day/$target" # => fonctionne pas
  mv "$1" "$trash_of_ze_day/$target_file"
}
alias tcn='rm_trash'
# This alias uses a little-known mv flag that enables you to provide the file you want to move as the final argument, ignoring the usual requirement for that file to be listed first. Now you can use your new command to move files and folders to your system Trash:
# $ ls 
# foo  bar
# $ tcn foo
# $ ls
# bar 
# Now the file is "gone," but only until you realize in a cold sweat that you still need it. At that point, you can rescue the file from your system Trash; be sure to tip the Bash and mv developers on the way out.
# Note: If you need a more robust Trash command with better FreeDesktop compliance, see Trashy.
# 
# => raccourci vers rm, carrément:
alias rm='tcn'



# Pour avoir des couleurs dans les greps divers, ainsi que dans les watches:
alias watch='watch -d -c'
# alias grep='grep --color=always'
# => oui mais non... autant c'est zouli à l'écran, autant dès qu'on tube |, ça débloque grave.


function cptimestampedarchive () {
  # (c'était naguère un script)
  #/bin/bash
  # Copie d'un féchier, donné en argument, vers une version archivée avec un horodatage en suffixe
  # cp -r $1{,_$(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g')}
  # cp -r -L $1{,_$(date +\%Y_\%m_\%d__\%T | sed -e 's/\:/_/g')} && \
  cp -r -L $1{,_$(date +\%Y_\%m_\%d__\%H_\%M_\%S)} && \
  echo -e "Copied $1 to timestamped backup: \n$(ls -l "$1")\n$(ls -trl "$1"_$(date +\%Y_\%m_\%d__*) | tail -1)"
}
alias backup_timestamp='cptimestampedarchive'
alias cpt='cptimestampedarchive'

# A simpler, and probably more universal, alias returns you to the Git project’s top level. This alias is useful because when you’re working on a project, that project more or less becomes your "temporary home" directory. It should be as simple to go "home" as it is to go to your actual home, and here’s an alias to do it:
alias cg='cd `git rev-parse --show-toplevel`'
# Now the command cg takes you to the top of your Git project, no matter how deep into its directory structure you have descended.


# Un alias pour lancer vim en mode "vivant", à savoir qui recharge automatiquement le contenu du féchier édité:
alias vi_live="vim $\"+:set autoread | au CursorHold * checktime | call feedkeys('lh')\" "
alias vil='vi_live'

# Connexion directe à psql avec $CONNINFO, ça simplifie des choses pour xbindkeys
alias psql_conninfo="psql $CONNINFO"

