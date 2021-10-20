#!/usr/bin/env python
# -*- coding: utf-8 -*-

#from decimal import *
from string import *
import re, pyparsing, sqlalchemy

# Ces 3 classes viennent d'un article de Sébastien Chazallet paru dans GLMFen septembre 2011: #{{{
class Extractor(object):#{{{
    def __init__(self, url):
        self.engine = sqlalchemy.create_engine(url)
    def __call__(self, request):
        connection = self.engine.connect()
        result = ResultSet(connection.execute(request).fetchall())
        #result = (connection.execute(request).fetchall())
        connection.close()
        return result
    #}}}

class RequestsManager(list):#{{{
    filename = 'requests.pkl'
    def __init__(self):
        if os.path.isfile(self.filename):
            f = open(self.filename, 'rb')
            for d in pickle.load(f):
                self.append(d)
            f.close()
        else:
            print('Nouveau fichier de données')
    def save(self):
        f = open(self.filename, 'wb')
        exported = []
        for d in self:
            exported.append(d)
        pickle.dump(exported, f)
        f.close()
    #}}}

class ResultSet(list):#{{{
    def __init__(self, result):
        for r in result:
            self.append(dict((a, b) for a, b in r.items()))
    def export(self, filename, columns):
        f = open(filename, 'w')
        w = csv.DictWriter(f, columns)
        #w.writeheader()
        w.writerows(self)
        f.close()
#}}}

#}}}


# @#TODO À REPRENDRE: 30/9/11 22:10 au pieu, écriture d'un parseur de mesures tecto:

def parse_tecto_measure(opid, obs_id, structure_measure_txt): # {{{
    """Part d'une mesure structurale sous forme de chaîne, du type:
     'Nm40/50/E/20/S/D',
    et renvoie un tuple
    (measure_type, north_ref, direction, dip, dip_quadrant, pitch, pitch_quadrant, movement, valid)
    ('PLANE_LINE_MOVT', 'Nm', 40, 50, 'E', 20, 'S', 'D', True)
    """
    #structure_measure_txt = 'Nm40/50/E/20/S/D'
    #if True:
    print "--"
    print "-- ##########debut parse_tecto_measure"
    try:
        # on initialise toutes les variables en sortie à None: de sorte que si 
        # elles ne sont pas définies, ça ne fera pas d'erreur à la fin, et qu'on 
        # pourra faire un return, qui aura des cases vides;
        # à l'utilisateur de les corriger par la suite.
        (measure_type, north_ref, direction, dip, dip_quadrant, pitch, pitch_quadrant, movement, valid) = (None        , None           , None     ,None, None        , None , None          , None    , None )
        valid = True    # on part du principe que la mesure courante est valide; 
                        # au besoin, on invalidera cette présomption de correction.
        items = structure_measure_txt.split('/')
        if len(items)   == 6:
            #6 éléments: c'est une mesure de plan avec ligne et mouvement, une faille:
            measure_type = 'PLANE_LINE_MOVT'
        elif len(items) == 5:
            #5 éléments: c'est une mesure de plan avec ligne, une faille sans mouvement:
            measure_type = 'PLANE_LINE'
        elif len(items) == 4:
            #4 éléments: ce doit être mesure de plan avec ligne déterminée par azimut ou plongement, sans mouvement:
            measure_type = 'PLANE_LINE'
        elif len(items) == 3:
            #3 éléments: c'est une mesure de plan:
            measure_type = 'PLANE'
        else:
            #ça ne ressemble pas à une mesure de plan ou faille
            measure_type = None
            valid = False
        print "-- measure_type: ", measure_type                     #DEBUG
        if measure_type in ('PLANE_LINE_MOVT', 'PLANE_LINE', 'PLANE'):
            #print "-- items: ", items                     #DEBUG
            if items[0][0:2] not in ( 'Nm', 'Ng', 'Nu'):
                print('-- invalid: structural measurement must begin with North reference definition: Nm or Ng or Nu, for Magnetic North, Geographic North, or UTM North')
                north_ref = ''
                valid = False
            else:
                north_ref = items[0][0:2]
            print "-- north_ref: ", north_ref #DEBUG
            direction = int(items[0][2:])
            print "-- direction: ", direction             #DEBUG
            if direction < 0 or direction > 180:
                print('-- invalid: direction must be between 0 and 180')
                valid = False
                #raise ValueError
            dip =  int(items[1])
            print "-- dip: ", dip                         #DEBUG
            if dip < 0 or dip > 90:
                print('-- invalid: dip must be between 0 and 90')
                valid = False
                #raise ValueError
            dip_quadrant =  str(items[2])
            print "-- dip_quadrant: ", dip_quadrant               #DEBUG
            if dip_quadrant not in 'NESW':
                print('-- invalid: dip quadrant must be N, E, S or W')
                valid = False
                #raise ValueError
        if measure_type in ('PLANE_LINE_MOVT', 'PLANE_LINE'):
            pitch =  int(items[3])
            print "-- pitch: ", pitch                     #DEBUG
            if pitch < 0 or pitch > 90:
                print('-- invalid: pitch must be between 0 and 90')
                valid = False
                #raise ValueError
            pitch_quadrant =  str(items[4])
            print "-- pitch_quadrant: ", pitch_quadrant   #DEBUG
            if pitch_quadrant not in 'NESW':
                print('-- invalid: pitch quadrant must be N, E, S or W')
                valid = False
                #raise ValueError
        if measure_type == 'PLANE_LINE_MOVT':
            movement =  str(items[5])
            print "-- movement: ", movement               #DEBUG
            if movement not in 'NIDS':
                print('-- invalid: movement must be N, I, D or S')
                valid = False
                #raise ValueError
            #return #Fault(north_ref, direction, dip, quadrant, pitch, pitch_quadrant, movement)
        if measure_type == 'PLANE':
            pitch          = None
            pitch_quadrant = None
            movement       = None
        if measure_type == 'PLANE_LINE':
            movement       = None
    except:
        print("-- exception!")                         #DEBUG
        return None
    finally:
        print "-- ########### FIN parse_tecto_measure"
        return (opid, obs_id, measure_type, north_ref, direction, dip, dip_quadrant, pitch, pitch_quadrant, movement, valid)
    #}}}

# Fabriquons un extracteur de données:
data_extractor = Extractor('postgresql://pierre:pp@autan/bdexplo')

# Sortons les descriptions de la table field_observations, avec la clé opid + obs_id:
list_descriptions = data_extractor("SELECT opid, obs_id, description FROM field_observations                                ORDER BY obs_id")
#                                                                                      WHERE description ILIKE '%Nm%' => apparemment, ça ne passe pas: bug de sqlalchemy?

# le réceptacle des mesures:
list_structural_measurements = []

# Traitons toutes les descriptions:
for desc in list_descriptions:
    opid        = desc['opid']
    obs_id      = desc['obs_id']
    print "-- "
    print "-- ######debut traitement observation %s#########" % obs_id
    description = desc['description']
    nb_measures = description.count("Nm")
    if nb_measures != 0:
        print "-- nb_measures: ", nb_measures
        i = 0
        while i < nb_measures:
            i += 1
            positionNm  = description.find("Nm")
            description = description[positionNm:]
            #print "-- description est maintenant: %s" % description
            mesure = re. split("[,; .]", description, maxsplit=1)[0]
            try:
                description = re. split("[,; .]", description, maxsplit=1)[1]
            except:
                description = ""        # si ça a échoué, c'est qu'une mesure terminait la description, sans ponctuation
            #print "-- Mesure n°", i, " -> ", mesure
            # observation_description = "Nm" + pyparsing.Regex(".*") + pyparsing.Regex("[ ,;.\t]")
            # observation_description.parseString(description)
            # positionfinmesure = description.find(" ")
            # mesure = re.split("[ ,.]", description[positionNm:])[0] 
            # mesure = 'Nm40/50/E/20/S/D'
            list_structural_measurements.append(parse_tecto_measure(opid, obs_id, mesure))

print
print "-- ======================"
print "-- Prêt pour tectri:"

##############################################################################################################################################################################################################################################################################################################################################################################################################################
# à la sortie, on voudra quelque chose comme ça:
#"opid", "obs_id", "description",   "north_ref", "measure_type", "structure_type",  "dir", "dip", "dipquad", "pitch",   "pitchquad",   "movt"   "azim", "pl",    "valid",  "comments"
# 
#    11,   "844",   "Parement appendice de fosse, saprolite d'un granitoïde, pas mal de quartz, de la séricite, apparence grenue. Veine de quartz ~6cm, Nm80/70/N, appartient à un stockwerk lâche. Plus loin, autre veine de quartz, Nm5/70/E/60/N, linéation = stries probablement. Autre veine de quartz: Nm15/20/E/Azi145 stries, jeu indéterminé. Faille, mesure bidon Nm40/50/E/20/S/D"
#    11,   "844",                    "Nm",             "plane"            , "vein" ,       80,    70,    "N",            ,               ,         ,         ,     ,    1, 
#    11,   "844",                    "Nm",             "plane_line"       , "vein" ,        5,    70,    "E",        60  ,     "N"       ,         ,         ,     ,    1,
#    11,   "844",                    "Nm",             "plane_line"       , "vein" ,       15,    20,    "E",            ,               ,         ,    145  ,     ,    0,
#    11,   "844",                    "Nm",             "plane_line_orient", "fault",       40,    50,    "E",        20  ,     "S"       ,    "D"  ,         ,     ,    1,
##############################################################################################################################################################################################################################################################################################################################################################################################################################

sql  = "INSERT INTO field_observations_struct_measures \n"
sql += "(opid, obs_id, measure_type, north_ref, direction, dip, dip_quadrant, pitch, pitch_quadrant, movement, valid) \n"
sql += "VALUES \n"
for i in list_structural_measurements:
    sql += str(i).replace("u'", "'").replace("None", "NULL") + ",\n"

sql = sql[:-2] + ";\n"

print "-- =============================================================="
print sql




""" #D'ici, tout horscommenté
class Fault(Plane_Line).
class Plane_Line(Plane)

class Plane(object):
  self.

# @#REPRENDRE TODO
# Poubelle:/*{{{*/
#Un premier essai:/*{{{*/
chaine = "rien"
while chaine != "":
    chaine = raw_input("Chaine à parser pour trouver des mesures structurales: ")
    chaine = chaine.replace("/", "\t")


from string import *
import re 
sep = "\t"

# on splitte jusqu'à une mesure, qui commence par "Nm"
for souschaine in chaine.split("Nm"):
    print souschaine 
    print
    if not(find(souschaine, "/")):
        #pas de /, donc il ne doit pas y avoir de mesure: 
        #on continue 
        continue 
    else:
        #il y a des /, donc ce doit être une mesure:
        #elle continue jusqu'au prochain blanc:
        mesure = souschaine.split(" ")[0]
        dir  = mesure.split("/")[0]
        pd   = mesure.split("/")[1]
        qdpd = mesure.split("/")[2]
        if find(mesure.split("/")[2], "/"):  #il y a une linéation
            pi   = mesure.split("/")[3]
            qdpi = mesure.split("/")[4]
            jeu  = mesure.split("/")[5]
        print(dir + sep + pd + sep + quadpd)
        if find(mesure.split("/")[2], "/"):
            print(sep + pi + 999999
#/*}}}*/



{{{
# préambule:
chaine = u"844  Parement appendice de fosse, saprolite d'un granitoïde, pas mal de quartz, de la séricite, apparence grenue. Veine de quartz ~6cm, Nm80/70/N, appartient à un stockwerk lâche. Plus loin, autre veine de quartz, Nm5/70/E/60/N, linéation = stries probablement. Autre veine de quartz: Nm15/20/E/Azi145 stries, jeu indéterminé."
# pour debug, avec la tabulation:
chaine = u"844\tParement appendice de fosse, saprolite d'un granitoïde, pas mal de quartz, de la séricite, apparence grenue. Veine de quartz ~6cm, Nm80/70/N, appartient à un stockwerk lâche. Plus loin, autre veine de quartz, Nm5/70/E/60/N, linéation = stries probablement. Autre veine de quartz: Nm15/20/E/Azi145 stries, jeu indéterminé."
print chaine

# avant la tabulation, c'est l'identifiant de l'observation: on l'appelle id
id = chaine.split("\t")[0]
print "id:", id                 #DEBUG

# on ne conserve que le reste de la chaîne après la tabulation, soit
# la description elle-même 
chaine = chaine.split("\t")[1]
print "il reste de chaine: ", chaine

# cherchons combien il y a de mesures référencées par un Nm...:
nb_measures = chaine.count("Nm")
print "nb_measures: ", nb_measures

/*{{{*/
# définition de la grammaire d'une ligne d'observation comprenant des mesures: (non)
observation_description = pyparsing.Regex(".*") + "Nm" + pyparsing.Regex(".*")
observation_description.parseString(chaine)

/*}}}*/
}}}

# /*}}}*/


:set foldclose=all
:set foldmethod=marker
:set syntax=python
:set autoindent
:set ts=4
:set sw=4
:set et
:%s/\t/    /gc

"""

