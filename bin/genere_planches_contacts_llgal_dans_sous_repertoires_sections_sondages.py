#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys,os, pdb
prefix_section   = "section"
drill_hole_label = "sondage"

initial_dir = os.getcwd()

for curr_dir, dirs, files in os.walk('.', followlinks=True):
	# on itère sur l'ensemble des répertoires, et on va générer, avec llgal, 
	# un album pour chaque répertoire, uniquement pour les sous-
	# répertoires de coupes de sondages.
	# Càd ceux qui commencent par prefix_section
	nom_court_repertoire_courant = curr_dir.split(os.sep)[-1]
	if nom_court_repertoire_courant[0] == ".": continue   # un répertoire caché, pas la peine, on zappe.
	try:
		nom_court_repertoire_parent  = curr_dir.split(os.sep)[-2]
	except:
		nom_court_repertoire_parent  = ''
	if nom_court_repertoire_parent[0:len(prefix_section)] != prefix_section: continue # on n'est pas dans un sous-répertoire d'un répertoire de coupes, zou
	# on est ici dans un sous-répertoire d'un répertoire de coupes
	print("Répertoire courant:\t" + nom_court_repertoire_courant)
	print("Répertoire parent: \t" + nom_court_repertoire_parent)
	print("=" * 50)
	print(nom_court_repertoire_parent[0:len(prefix_section)])
	print(prefix_section)
	print("#" * 80)
	print("curr_dir:\t" + curr_dir)
	print("-" * 50)
	print("files:\t")
	#print(files)
	print("-" * 50)
	title = (curr_dir.split(os.sep)[-2].capitalize().replace("_", " ") + ", " + drill_hole_label + " "+ curr_dir.split(os.sep)[-1])
	initial_dir = os.getcwd()
	os.chdir(curr_dir)
	ligne_cmd  = "llgal -u --exif --cc exifdesc -s -n --tx 250 --ty 250 -w 3 --title '"
	ligne_cmd += title + "' -p 5"
	ligne_cmd += " && firefox index.html"
	sys.stdout.flush()
	print(ligne_cmd)
	os.system(ligne_cmd)
	print("\n__________________")
	os.chdir(initial_dir)
	#print(files)



"""
POUBELLE
		print(curr_dir)
		#pdb.set_trace() ################## DEBUG #################
		if (curr_dir.split(os.sep)[-2][0:len(prefix_section)] == prefix_section):
						
"""

