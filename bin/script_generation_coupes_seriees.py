#!/usr/bin/env python
#generation d'une serie de coupes a partir de la definition prise dans la bd postgresql: SELECT id, location, ll_corner_x, ll_corner_y, ll_corner_z, azim_ng, interval, num_start, count, length, title FROM sections_definition ORDER BY id;
from math import *

# parametres, a adapter #########################

#id	=1
#location	="UMA"
#ll_corner_x	= 742613.58 #742602.09    #742574
#ll_corner_y	= 2058742.38 #2058758.67 # 2058886
#ll_corner_z	=490
#azim_ng	=55.6
#interval	=25
#num_start	=-1
#count	=39
#length	=200
#title	="Umashar coupe"

id	=1
location	="GBEITOU1"
ll_corner_x	= 601570
ll_corner_y	= 760290
ll_corner_z	= 300
azim_ng	        = 45 
interval	= 40
num_start	= 1
count	        = 8
length	        = 350
title	        = "Gbeitouo 1 - coupe"
srid            = 36629


sep          = "," #"\t"
sepchar   = "\'"
# ################################################


#CREATE FUNCTION 
#def cross_sections_array(location varchar(20), ll_corner_x numeric(10,2), ll_corner_y numeric(10,2), ll_corner_z numeric(10,2), azim_ng numeric(10,2), interval numeric(10), num_start integer, count numeric(3), length numeric(5), title varchar(254)):
#RETURNS string AS $$
sortie = []
num   = 1
indice_coupe = num_start
#sql_insert = "DROP VIEW tmp_coupes_seriees_plines;\n"
#sql_insert = sql_insert + "DROP TABLE tmp_coupes_seriees;\n"
#sql_insert = sql_insert + "CREATE TABLE tmp_coupes_seriees (num integer PRIMARY KEY, id VARCHAR(20), title VARCHAR(254), srid integer, x1 NUMERIC(10,2), y1 NUMERIC(10,2), z1 NUMERIC(10,2), x2 NUMERIC(10,2), y2 NUMERIC(10,2), z2 NUMERIC(10,2));\n"
sql_insert = "DELETE FROM tmp_coupes_seriees WHERE id ILIKE  '" + location + "%';\n"
sql_insert = sql_insert + "INSERT INTO tmp_coupes_seriees (num, id, title, srid, x1, y1, length, z1, x2, y2, z2) VALUES \n"
for i in range(count):
    out = ""
    out = str(num)   +sep+   sepchar+ location+str(indice_coupe).zfill(3) +sepchar   +sep+   sepchar+ title+" "+str(indice_coupe) +sepchar   +sep + str(srid) + sep
    x2 = ll_corner_x+interval*(i) * cos((90.0-azim_ng)/180*pi)
    y2 = ll_corner_y+interval*(i) * sin((90.0-azim_ng)/180*pi)
    x1 = x2 - length * sin((90.0-azim_ng)/180*pi)
    y1 = y2 + length * cos((90.0-azim_ng)/180*pi)
    z  = ll_corner_z
    out = out + str(x1) + sep + str(y1) + sep + str(z) + sep + str(length) + sep + str(x2) + sep + str(y2) + sep + str(z)
    sql_insert = sql_insert + "("+out+"),\n"
    num = num + 1
    indice_coupe = indice_coupe + 1
    #print out
    #sortie.append(out)
sql_insert = sql_insert[0:len(sql_insert)-2]
sql_insert = sql_insert + ";\n"

#sql_insert = sql_insert + "CREATE VIEW public. tmp_coupes_seriees_plines AS SELECT *, geomfromewkt('SRID = ' || srid || '; LINESTRING (' || x1 || ' ' || y1 || ', ' || x2 || ' ' || y2 || ')') FROM tmp_coupes_seriees;\n"

#print sortie

print
print
print sql_insert

