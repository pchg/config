#!/usr/bin/env python
# -*- coding: utf-8 -*-

import psycopg2, subprocess, os
from datetime import datetime

dbname  = 'bdexplo'
dbhost  = 'autan'
user    = 'pierre'

sauvg="export_" + dbhost + "_" + dbname + "_" + datetime.now().strftime("%Y_%m_%d_%Hh%M")

print("Sauvegarde de la base %s sur l'hôte %s en fichiers .csv dans le répertoire %s..." % (dbname, dbhost, sauvg))
os.mkdir(sauvg)
os.chdir(sauvg)

# Connect to an existing database
conn = psycopg2.connect(database=dbname, user=user, host=dbhost)
# Open a cursor to perform database operations
cur = conn.cursor()

# on prend la liste des tables dans le schéma public, le seul qu'on sauvegarde:
# Query the database and obtain data as Python objects
cur.execute("SELECT tablename FROM pg_tables WHERE schemaname = 'public';")
# Build a string containing shell instructions
shellstring = ""
for table in cur.fetchall():
    t = table[0]
    #shellstring += """echo "COPY (SELECT * FROM public.%s WHERE opid IN (11, 18)) TO stdout WITH CSV HEADER" | psql -X %s -h %s > %s.csv\n""" % (t, dbname, dbhost, t)
    shellstring += """echo "COPY (SELECT * FROM public.%s                       ) TO stdout WITH CSV HEADER" | psql -X %s -h %s > %s.csv\n""" % (t, dbname, dbhost, t)

# on exécute la ligne de commande
p = subprocess.call(shellstring, shell=True)

print("Fini")
