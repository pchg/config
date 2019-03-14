#!/bin/bash

shopt -s dotglob
cd ..
pwd
for f in config/*
#cd ~
do
 if [ -a $f ]      # si f existe
  then
   mv $f $f.old    # on le renomme .old
  fi
 ln -s $f .        # et sinon, on fait un lien symbolique
done

# remove unwanted symlinks (TODO can be vastly improved)
rm .git
rm README.md
rm create_symlinks.sh

