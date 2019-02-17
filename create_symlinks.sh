#!/bin/bash

shopt -s dotglob
cd config
for f in *
cd ~
do
 if [ -a $f ]       # si f existe
  then
   mv $f $f.old    # on le renomme .old
  fi
 ln -s $f .
done

# remove unwanted symlinks (TODO can be vastly improved)
rm .git
rm README.md
rm create_symlinks.sh
#rm ~/.gitconfig # Ah non!

