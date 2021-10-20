#!/bin/sh
# Change le ' par un _ des repertoires et appelle a sanity.pl pour "nettoyer les noms des fichiers"

for filename in *
do
        if [[ -d $filename ]]; then
                n=`echo "$filename/" | tr '['"\'"']' '[_]'`
                n=${n%/}
                [[ $filename == $n ]] || mv "$filename" "$n"
                cd "$n"
                echo "En repertoire $n"
                renommage.sh
                cd ..
                echo "on remonte"
        else
                sanity.pl "$filename"
        fi
done

exit $?
