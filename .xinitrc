# Ça lance la partie GUI
# typiquement, lancement de xmodmap, xkbcomp, xrdb
# et lancement d'un session manager ou d'un window manager

###############
   # ~/.xinitrc is executed by xinit, which is usually invoked via startx. This program is executed after logging in: first you log in on a text console,
   # then you start the GUI with startx. The role of .xinitrc is to start the GUI part of the session, typically by setting some GUI-related settings such
   # as key bindings (with xmodmap or xkbcomp), X resources (with xrdb), etc., and to launch a session manager or a window manager (possibly as part of a
   # desktop environment).
###############

# Enlightenment inserted Execution string here
#exec /usr/bin/enlightenment

xrdb -merge ~/.Xresources
xbindkeys_autostart &
# icewmbg -k gray -p
# demarrage &
xterm &
# icewm-session &
#blackbox
#wmaker
#xfce4-session
#fluxbox
# icewmbg &
#gnome-session
#enlightenment
#kwin
