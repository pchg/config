#!/bin/bash
echo "Creation of symlinks in upper directory .. , pointing to various configuration files in 'config' current directory . (`pwd`)"
cd ..
#shopt -s dotglob
for f in `ls -a config/`
do
 echo "$f"
 if [ -a $f ]      # si f existe                             # if f exists
  then
   mv $f $f.old    # on le renomme .old                      # it is renamed to .old
 fi
 ln -s config/$f . # et sinon, on fait un lien symbolique    # otherwise, make a symlink
done

#   echo "coucou"
# remove unwanted symlinks (TODO can be vastly improved)
rm .git
rm README.md
rm create_symlinks.sh
rm tectri.ini

