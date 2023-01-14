#!/usr/bin/env python
import os
#os.system("cd ~/notes")
fichier_pdb       = "notes.pdb"
fichier_txt       = "notes.txt"
repertoire        = "/home/pierre/notes"
repertoire_sauvgs = "okz"

os.chdir(repertoire)

#synchro_notes_pdb_zire_get
print "1 - allons chercher les notes dans le zire:"
print "    appuyons donc sur la saint-kro..."
#os.system("pilot-xfer -p /dev/ttyUSB1 -f " + repertoire + os.sep + fichier_pdb)
#os.system("pilot-xfer -p /dev/ttyUSB1 -f "+ fichier_pdb)
os.system("pilot-xfer -p usb: -f "+ fichier_pdb)

print "1 et demi - sauvegardons, sétonjamais"
nouveau_repertoire_sauvg = repertoire+os.sep+repertoire_sauvgs+os.sep+str(max(map(int,(os.listdir(repertoire_sauvgs))))+1)+os.sep
print "-> sauvegarde dans "+ nouveau_repertoire_sauvg
os.mkdir(nouveau_repertoire_sauvg)
os.system("cp notes.txt "+nouveau_repertoire_sauvg)
os.system("cp notes.pdb "+nouveau_repertoire_sauvg)

print "2 - convertissons"
print ", et éditons dans la foulée:"
#os.system("cp notes/notes.pdb notes/notes.pdb.okz")
os.system("txt2pdbdoc -d notes.pdb notes.txt")

