#!/bin/bash
FILES=*
for f in $FILES
do
 ln -s $f ~
done
