#!/usr/bin/env python
# -*- coding: utf-8 -*-
# decodage mrsid en jpg2000: /*{{{*/
# Décodons les mrSid proprios, faisons-en des geotiffs, puis des jpeg2000.

import sys
import os

# La liste des identifiants des tuiles à décoder,
# telle que retournée par un bête copier-coller depuis qgis, 
# en prenant la sélection de la table attributaire de 
# ~/sig/scans/ign_scan25/ta_scan25/scan25_region.shp
# avec quelques ' et , en plus:
deja_traite_ignorer = """list_id_scans_to_decode = [
'F091_080',
'F094_079',
'F092_080',
'F093_080',
'F094_080',
'F091_077',
'F092_077',
'F091_078',
'F093_077',
'F092_078',
'F094_077',
'F093_078',
'F091_079',
'F094_078',
'F092_079',
'F093_079'
]
"""

list_id_scans_to_decode = [
'F029_085',
'F032_085',
'F028_086'
]
"""
'F029_086',
'F030_086',
'F031_086',
'F032_086',
'F029_087',
'F030_087',
'F031_087',
'F032_087',
'F028_084',
'F029_084',
'F030_084',
'F031_084',
'F032_084',
'F028_085',
'F030_085',
'F031_085'
]
"""


# le répertoire où on met le bazar résultant; par défaut, ~/tmp semble approprié:
output_path = '~/tmp/'
# le taux de compression; 0.05 est bien.
rate = 0.05

# bouclons sur cette liste:
for i in list_id_scans_to_decode:
    # on fait les variables
    tif_file = i.lower() + '.tif'
    sid_file = tif_file  +     '.sid'
    jpg_file = i.lower() + '.jp2'
    # on construit la ligne de commande:
    ligne_cmd = 'mrsidgeodecode_linux -i ' + sid_file + ' -o ' + output_path + tif_file + ' -of tifg'
    ligne_cmd += '\n'
    ligne_cmd += 'gdal_translate -of JPEG2000 ' + output_path + tif_file + ' ' + output_path + jpg_file + ' -co "rate=' + str(rate) + '"'
    print
    # on imprime la ligne de commande, pour contrôle:
    print ligne_cmd
    # puis on flushe et on runne:
    sys.stdout.flush()
    os.system(ligne_cmd)

#/*}}}*/

