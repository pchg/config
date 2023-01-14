#!/usr/bin/env python
# -*-coding=utf-8
import os
import time 
#os.system("cd ~/notes")
fichier_pdb       = "notes.pdb"
fichier_txt       = "notes.txt"
repertoire        = "/home/pierre/notes"
repertoire_sauvgs = "okz"

os.chdir(repertoire)
#faire un répertoire, en incrémentant:
#nouveau_repertoire_sauvg = repertoire+os.sep+repertoire_sauvgs+os.sep+str(max(map(int,(os.listdir(repertoire_sauvgs))))+1)+os.sep

#=> bof, plutôt faire un répertoire avec la date courante:
lt = time.localtime()      #lt  = local time
lts = map(str, lt)         #lts = local time string
nouveau_repertoire_sauvg = repertoire+os.sep+repertoire_sauvgs+os.sep+ lts[0] + "_" + ("0" + lts[1])[-2:] + "_" + ("0" + lts[2])[-2:] + "_" + ("0" + lts[3])[-2:] + "_" + ("0" + lts[4])[-2:] + "_" + ("0" + lts[5])[-2:]

print "-> sauvegarde dans "+ nouveau_repertoire_sauvg
os.mkdir(nouveau_repertoire_sauvg)
os.system("cp notes.txt "+nouveau_repertoire_sauvg)
os.system("cp notes.pdb "+nouveau_repertoire_sauvg)
os.system("rm -f sauvg_der")
os.system("ln -s " + nouveau_repertoire_sauvg + " sauvg_der")
