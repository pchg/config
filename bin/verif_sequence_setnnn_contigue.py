#!/usr/bin/env python
import os, fileinput, glob, sys, string, sets
#, re

def extrait_indice_photo(nomfichier_palm_jpg):
    indice=0
    try:
        indice = string.replace(nomfichier_palm_jpg,"Set","")
        indice = string.replace(indice,".jpg","")
        #premier_indice = string.replace(premier_indice,"_?","")
        indice = string.atoi((string.split(indice,"_"))[0])
        return indice
    except :
        pass



if len(sys.argv) == 1:
	#nomfichiers = os.listdir(os.curdir)
    nomfichiers = glob.glob("*.jpg")
else:
	nomfichiers = sys.argv[1:]

#print nomfichiers
#print "========================================="
print "Liste des fichiers *.jpg du répertoire courant..."
nomfichiers.sort()
#print nomfichiers

#premier_indice = extrait_indice_photo(nomfichiers[1])
#dernier_indice = extrait_indice_photo(nomfichiers[-1])

sequence_indices_fichiers = map(extrait_indice_photo, nomfichiers)

sequence_indices_fichiers.sort()
premier_indice = sequence_indices_fichiers[1]
dernier_indice = sequence_indices_fichiers[-1]
#print sequence_indices_fichiers

print "recherche de l'indice (XXX) dans le pattern SetXXX_YY.jpg..."
print "premier indice: ",
print premier_indice 
print "dernier indice: ",
print dernier_indice

sequence_continue = range(premier_indice,dernier_indice)


indices_manquants = sets.Set(sequence_continue).difference(sets.Set(sequence_indices_fichiers))
indices_manquants = (list(indices_manquants))
indices_manquants.sort()

print "indices manquants dans la séquence: "
print indices_manquants


#poubelle:
    #premier_indice = string.replace(nomfichiers[1],"Set","")
    #premier_indice = string.replace(premier_indice,".jpg","")
    ##premier_indice = string.replace(premier_indice,"_?","")
    #premier_indice = string.atoi((string.split(premier_indice,"_"))[0])

    #dernier_indice = string.replace(dernier_indice,".jpg","")
    ##dernier_indice = string.replace(dernier_indice,"_?","")
    #dernier_indice = string.atoi((string.split(dernier_indice,"_"))[0])
    #print premier_indice
    #print dernier_indice
