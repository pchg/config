#!/usr/bin/env python
# -*-coding=utf-8
#premier calcul, le 2009/02/05
#notes = [20,11,10,18,12.5,19,11,6.5,15.5,16,15,17,15,11.5,6.5,10,13,4.5,11.5,9,16,12,13.5,9,10,11,14,14,20]

#second calcul, le 2009/06/21
#notes = [13.5,5.5,15,6,16,8,14.5,19,14,20,20,11,10,11.5,18,11.5,17,11.5,13,14,19,12.5,6,7.5,12.5,7,6,13,8.5,12,16,14.5,14,17,11.5,8,18,15,12,13.5,10,8.5,10,11,17,17.5,12.5,14,13.5,18,20,18.5]

#troisième calcul, le 2010/11/7
#plumeur = 'Louis'  #auparavant, calcul que pour Louis
#notes = [16.5, 5, 8.5, 5.5, 19, 11.5, 14, 1, 15, 7, 11.5, 15, 16, 16, 11.5, 16, 16, 16, 16, 20, 9.5, 16, 18.5, 11.5, 17.5, 17.5]

#quatrième calcul, le 2010/11/10
#plumeur = 'Madialen'
#notes = [6.5*2, 17.25, 16.5, 9*2, 15.5, 19, 20, 20, 15.5, 14, 14,   5.5*2, 5*1,          11.5, 17, 17, 3.5*4, 5*2, 2*4, 17]
#                                                                       ^- note était sur 10
#                                                                            ^- notes sur 10 ou 20??? => mise sur 20, par défaut

#cinquième calcul, le 07/07/2011
#plumeur = 'Madialen'
#notes = [14, 19, 16, 5.5*2, 16.5, 12, 10.5, 18.5, 12.5, 13.5, 16, 14.5, 18, 17, 14.5, 10*2, 9*2, 8.5*2, 14.5, 7*2, 12]

#sixième calcul, le 07/07/2011
plumeur = 'Louis'
notes = [11, 17.5, 11.5, 8, 16, 7.5, 19, 10.5, 4.5/2, 14, 17, 6.5*2, 12, 7*2, 7*2, 8*2, 11, 0]



note_sup = 15.0 #au-dessus de cette note, chaque point rapporte
note_inf = 10.0 #au-dessous de cette note, chaque point s'ôte
bareme   = 1.0  #sou rapporté par point

sousous  = 0.0  #la somme initiale à zéro

print "------====== début calcul de plumage ======------"
print "Somme acquise: %r euros" % sousous
for note in notes:
	#rien = raw_input()
	print " Note: %r/20" % note
	if note > note_sup:
		sousous = sousous + (note - note_sup) * bareme
		print "  -> au-dessus de %r/20, rapporte donc %r euros;" % (note_sup, (note - note_sup) * bareme)
		print "     félicitations.                                                  :-)"
		if note > note_sup + (note_sup - note_inf) / 2:
			print "     et mêmes CHAUDES félicitations.                                 B-)"

	if note < note_inf:
		sousous = sousous - (note_inf - note) * bareme
		print "  -> au-dessous de %r/20, %r euros sont donc retranchés;"  % (note_inf, (note - note_inf) * bareme)
		print "     PAS DE félicitation.                                            :-("
		if note < note_inf / 2:
			print "     MAIS ALORS VRAIMENT PAS DE félicitation.                        :-["
	elif note_inf <= note <= note_sup:
		print "  -> entre %r et %r, \npas de raison de rétribuer ni de punir, RAS.  :-|" % (note_inf, note_sup)
	print " Somme acquise: %r euros\n" % sousous

#print "Au final, somme: %r euros" % sousous
print "------====== fin calcul de plumage ======------"
if sousous < 0:
	print "Verdict: " + plumeur + " nous doit des sousous," + (str(abs(sousous))) + "euros...                     ;-("
elif sousous > 0:
	print "Verdict: " + plumeur + " nous plume de " + (str(abs(sousous))) + "euros...                             :-)"
elif sousous == 0:
	print "Verdict: match nul, personne ne doit rien à personne ni ne plume personne...                           :-|"


