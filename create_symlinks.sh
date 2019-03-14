#!/bin/bash

shopt -s dotglob
pwd
for f in *
#cd ~
do
 if [ -a ../$f ]      # si f existe
  then
#   if [ $f != config ]
#    then
     mv ../$f ../$f.old    # on le renomme .old (à moins que ce ne soit le répertoire config)
#   fi
  fi
 ln -s $f ..        # et sinon, on fait un lien symbolique
done

# remove unwanted symlinks (TODO can be vastly improved)
rm ../.git
rm ../README.md
rm ../create_symlinks.sh

