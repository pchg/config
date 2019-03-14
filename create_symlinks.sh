#!/bin/bash

shopt -s dotglob
pwd
for f in *
do
 if [ -a ../$f ]      # si f existe
  then
     mv ../$f ../$f.old    # on le renomme .old
  fi
 ln -s ../config/$f ..        # et sinon, on fait un lien symbolique
done

# remove unwanted symlinks (TODO can be vastly improved)
rm ../.git
rm ../README.md
rm ../create_symlinks.sh
rm ../tectri.ini

