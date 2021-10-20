#!/usr/bin/env python
#modif de la bd sondages en mettant les profondeurs debut quand elles n'y sont point

#parametres#######################
bd = "amc"
hote = "localhost"
useur = "pierre"
lepasse = "p"
table = "dh_sampling"
critere = "%"
##################################

import pg
#db = pg.connect("amc", host="localhost", user="pierre", passwd="p")
db = pg.connect(bd, host = hote, user = useur, passwd = lepasse)

sql= " SELECT id, depfrom, depto from %s WHERE id like '%s' AND depfrom IS NULL order by id, depto; " % (table, critere)
res=db.query(sql)
ListeEnregistrements=res.getresult()
print "%i enregistrements a traiter" % len(ListeEnregistrements)


sql= " SELECT id, depfrom, depto from %s WHERE id like '%s' order by id, depto; " % (table, critere)
res=db.query(sql)
ListeEnregistrements=res.getresult()
print "%i enregistrements dans la table" % len(ListeEnregistrements)


sondageprecedent = ""
deptoprecedent = 0
for i in range(len(ListeEnregistrements)):
	sondagecourant = ListeEnregistrements[i][0]
	depfrom = ListeEnregistrements[i][1]
	depto = ListeEnregistrements[i][2]
	if depfrom == None:
		if sondagecourant != sondageprecedent:
			depfrom = 0
			print "Debut ouvrage %s..." % sondagecourant
			sqlmaj = "UPDATE dh_sampling SET depfrom = %f WHERE id = '%s' AND depto = %f ;" % (depfrom, sondagecourant, depto)
			maj = db.query(sqlmaj)
			deptoprecedent = depto
			sondageprecedent = sondagecourant
		else:
			depfrom = deptoprecedent
			sqlmaj = "UPDATE dh_sampling SET depfrom = %f WHERE id = '%s' AND depto = %f ;" % (depfrom, sondagecourant, depto)
			maj = db.query(sqlmaj)
			deptoprecedent = depto
			sondageprecedent = sondagecourant

