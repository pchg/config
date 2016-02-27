#!/bin/bash
cd ~/config
shopt -s dotglob
for f in *
do
 ln -s ~/config/$f ~
done

# remove unwanted symlinks (TODO can be vastly improved)
rm ~/.git
rm ~/README.md
rm ~/create_symlinks.sh

