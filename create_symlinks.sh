#!/bin/bash
cd ~/config
shopt -s dotglob
for f in *
do
 # if f existe
 if [ -a ~/$f ]
  then
  #  on le renomme .old
   mv ~/$f ~/$f.old
  fi
 ln -s ~/config/$f ~
done

# remove unwanted symlinks (TODO can be vastly improved)
rm ~/.git
rm ~/README.md
rm ~/create_symlinks.sh
#rm ~/.gitconfig # Ah non!

