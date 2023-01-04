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


export CONNINFO=$CONNINFO_PAR   # ATTENTION!!! définition de CONNINFO_PAR   par défaut
export CONNINFO=$CONNINFO_MALEM # ATTENTION!!! définition de CONNINFO_MALEM par défaut
export CONNINFO=$CONNINFO_PIERRE # ATTENTION!!! définition de CONNINFO_PIERRE par défaut
export CONNINFO=$CONNINFO_GLL   # ATTENTION!!! définition de CONNINFO_GLL   par défaut

# export GLL_BD_USER=$PAR_BD_USER
# export GLL_BD_PORT=$PAR_BD_PORT
# export GLL_BD_HOST=$PAR_BD_HOST
# export GLL_BD_NAME=$PAR_BD_NAME
########################################################################################
########################################################################################





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
alias llls='ls -trlh | tail -50'
alias lllls='ls -trlh | tail -100'

#alias der_fichier='(ls --group-directories-first -Htr | tail -1)'
export der_fichier=`ls --group-directories-first -Htr | tail -1`
alias der_fichier=`ls --group-directories-first -Htr | tail -1`

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
alias v='less -SiN'   #pareil, mais le V est plus à main pour la gauche, avec la droite à la souris
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


if [ `whoami` = "root" ] ; then
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

#BCPPLUS d'historique!! suivons le conseil démesuré de http://www.oreillynet.com/onlamp/blog/2007/01/whats_in_your_bash_history.html
export HISTFILESIZE=10000000000000
export HISTSIZE=10000000000
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

# Je me fais un prompt qui permette de copier-coller sans avoir à retrafiquer:
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
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
#PS1=" \033[0;32m# \u@\h: \033[0m\w $(__git_ps1)  < \D{%Y_%m_%d__%T} >  [bashpid_$BASHPID]\n"

# => ces fioritures avec du git ne fonctionnent correctement que quand on démarre un bash dans un répertoire git, pas sinon.
# 2020_11_02__09_19_28 j'ajoute juste une ligne pour l'état du git, à partir du prompt précédent:
PS1=" \033[0;32m# \u@\h: \033[0m\w < \D{%Y_%m_%d__%T} > [bashpid_$BASHPID \#]"
#PS1+='\[\033[38;5;63m\]'
#PS1+='$(if git rev-parse --git-dir > /dev/null 2>&1; then echo " \[\033h[38;5;63m\]["; fi)\[\033[38;5;202m\]'
PS1+='$(if git rev-parse --git-dir > /dev/null 2>&1; then echo " \[\033[38;5;63m\]["; fi)\[\033[38;5;202m\]$(git branch 2>/dev/null | grep "^*" | colrm 1 2)\[\033[38;5;63m\]$(if git rev-parse --git-dir > /dev/null 2>&1; then echo "]"; fi)'
PS1+="\033[0m\n"


export BROWSER=firefox

alias htop='htop -d 50'
alias htopbg='htop -d 600'
alias px='ps faux | grep -v "grep faux" | grep -i -e VSZ -e'
#alias px='ps auxf | grep -v grep | grep -i -e VSZ -e'
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
export PATH="$PATH:$HOME/.gem/ruby/2.7.0/bin"
# export GEM_HOME=$HOME/.gem
# export GEM_PATH=$HOME/.gem

