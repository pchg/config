#!/bin/bash

DEBUG=0
DEBUG=1

echo_debug() {
  if [[ ${DEBUG} -eq 1 ]]; then
    echo -e "$*"
  fi
}

# Réinitialiser tout verrouillage précédent
# xmodmap -e "clear Lock"
setxkbmap -option

CAPS_STATE=$(xset -q | grep "Caps Lock:")
echo_debug ${CAPS_STATE}

regexp="Caps Lock:[ \t]*on.*"
if [[ ${CAPS_STATE} =~ ${regexp} ]]; then
  echo_debug "Caps on!"
  # xmodmap -e "add Lock = Caps_Lock"
  # => ne fonctione pas comme prévu
  setxkbmap -option
else
  echo_debug "Caps off!"
  # xmodmap -e "remove Lock = Caps_Lock"
  # => ne fonctione pas comme prévu
  setxkbmap -option ctrl:nocaps
fi

