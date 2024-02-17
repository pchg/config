#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Un programme mettant en evidence l'inutilite de l'orthographe pour la comprehension d'un texte"""
from random import *
import string, sys

def scramble_text(text):
    mots = text.split(" ")
    textout = []
    mot = ""
    for mot in mots:
        mott = []                                      #liste equivalent au mot
        motout = []                                    #mot en sortie, qui sera invretrtvi
        for i in range(len(mot)): mott.append(mot[i])  #on convertit simplement le mot en une liste de lettres; pour pouvoir popper, plus loin
        if len(mot)>3:                                 #sinon, un mot de 3 lettres ne change pas
            motout.append(mot[0])
            fin=mott.pop()
            while (len(mott)>1):                      
                #for j in range(len(mott)):
                motout.append(mott.pop(randrange(1, (len(mott)))))
            motout.append(fin)
            textout.append(motout)
        else:
            textout.append(mott)
        textout.append(" ")
    # FIXME boucler si jamais le mot mélangé est égal au mot initial
    # FIXME si la fin du mot est une (ou plusieurs) ponctuation(s), la stocker, réduire le mot, traiter le mot, puis rajouter la(les) ponctuation(s)

    textsortie = ""
    for tmp in textout:
            word = ""
            for ltr in tmp:
                    word = word+ltr #+" "
            textsortie = textsortie+word
    
    return(textsortie)



if (__name__ == '__main__'):
    cmd_line = (sys.argv)
    if len(cmd_line) > 1:
        text = cmd_line[1]
    else:
        text ="Arrêtez de m'emmerder avec les corrections orthographiques de merde"

#print('_' * 80)
#print('               .oO== texte original:   ==Oo.')
#print(text)
#print('_' * 80)
#print('')
#print('_' * 80)
#print('               .oO== txete oirignal:   ==Oo.')
print(scramble_text(text))
#print('_' * 80)

