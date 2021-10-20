; RACCOURCIS PRATIQUES POUR GDM
; paramètres:
demi_epaisseur_coupe =  5
;decalage            =  25   ;décalage pour shifter la fenêtre en Y d'une coupe
;                            ;non; on prend plutôt la différence
x_icon_piscine      = 345
y_icon_piscine      =  80
x_icon_print        =  21    ;position de l'icône quand panneau à gauche détaché et que fenêtre document graphique MDI en plein écran
y_icon_print        =  79
attente_ms          = 000
nb_coupes           =  50


;###############################################################################
; Décalage de coupes
;GDM coupe ligne brisée en avant; coupe suivante = Ctl-PgDn/*{{{*/
^PgDn::
;^F7::
Click %x_icon_piscine%, %y_icon_piscine%
WinWaitActive, Définir Vue, 
Send, {SHIFTDOWN}{TAB}{SHIFTUP}
Send, {DOWN}
Sleep %attente_ms%
Send, {TAB}{TAB}{TAB}{TAB}-%demi_epaisseur_coupe%{TAB}%demi_epaisseur_coupe%
Sleep %attente_ms%
;Send, {TAB}{TAB}{TAB}{TAB}{TAB}
Send, {ENTER}
;Send, {F8}
return
;###############################################################################
;/*}}}*/

;GDM coupe ligne brisée en arrière; coupe précédente = Ctl-PgUp/*{{{*/
^PgUp::
;^F8::
Click %x_icon_piscine%, %y_icon_piscine%
WinWaitActive, Définir Vue, 
Send, {SHIFTDOWN}{TAB}{SHIFTUP}
Send, {UP}
Sleep %attente_ms%
Send, {TAB}{TAB}{TAB}{TAB}-%demi_epaisseur_coupe%{TAB}%demi_epaisseur_coupe%
Sleep %attente_ms%
Send, {ENTER}
;Send, {F8}
return
;###############################################################################
;/*}}}*/

;GDM décalage de la coupe courante dans les y de (decalage) vers l'avant:
;^
F:: ; comme Forward, sous l'index gauche avec le repère clavier (ajouté Ctrl, sinon, trop de waï lorsqu'on tape un texte bêta)
decale_coupe(-1, 1)
return

;^
+F:: ; comme Forward, sous l'index gauche avec le repère clavier
; avec shift, une demi-épaisseur de décalage
decale_coupe(-1, 0.5)
return

;GDM décalage de la coupe courante dans les y de (decalage) vers l'arrière:
;^
D:: ; comme Descendre, sous le majeur gauche (ajouté Ctrl, sinon, trop de waï lorsqu'on tape un texte bêta)
decale_coupe(1, 1)
return

;^
+D:: ; comme Descendre, sous le majeur gauche
; avec shift, une demi-épaisseur de décalage
decale_coupe(1, 0.5)
return
;###############################################################################


;###############################################################################
;GDM enfoncement plan courant de decalage vers le bas:
;^
R:: ; comme sur Forward, comme Raise, ou plutôt comme Remonte, sous l'index gauche, en montant depuis F (ajouté Ctrl, sinon, trop de waï lorsqu'on tape un texte bêta)
enfonce_plan(-1, 1)
return

;^
+R:: ; comme sur Forward, comme Raise, ou plutôt comme Remonte, sous l'index gauche, en montant depuis F
; avec shift, une demi-épaisseur de décalage
enfonce_plan(-1, 0.5)
return


;GDM enfoncement plan courant de decalage vers le haut:
;^
E:: ; comme à gauche de R, comme Enfonce, sous le majeur gauche en remontant (ajouté Ctrl, sinon, trop de waï lorsqu'on tape un texte bêta)
enfonce_plan(1, 1)
return

;GDM enfoncement plan courant de decalage vers le haut:
;^
+E:: ; comme à gauche de R, comme Enfonce, sous le majeur gauche en remontant
; avec shift, une demi-épaisseur de décalage
enfonce_plan(1, 0.5)
return
;###############################################################################


;###############################################################################
;GDM génération de n coupes sériées
^!+P:: ; comme une combinaison de touches absconse, ctrl-alt-shift-P
Loop, %nb_coupes% {
    Click %x_icon_print%, %y_icon_print%
    Sleep %attente_ms%
    WinWaitActive, Impression,
    Send, {ENTER}
    Sleep %attente_ms%
    WinWaitActive, PDFCreator 1.0.2,
    Sleep %attente_ms%
    Send, {TAB}{TAB}
    Send, {CTRLDOWN}{INS}{CTRLUP}
    Sleep %attente_ms%
    Send, {SHIFTDOWN}{TAB}{SHIFTUP}
    Sleep %attente_ms%
    Send, {SHIFTDOWN}{INS}{SHIFTUP}
    Sleep %attente_ms%
    Send, {ENTER}
    WinWaitActive, Enregistrer sous...
    Send, {ENTER}
    ;MsgBox This is ok. On décale la coupe.
    ;WinWaitActive, "GDM-[coupe_mobile]",
    Sleep 1000
    decale_coupe(-1, 1)
    ;MsgBox This is ok. La coupe serait décalée.
}
return
;###############################################################################




;###############################################################################
;fonctions utilitaires: /*{{{*/
ToNumeric(x) ;/*{{{*/
{
;MsgBox %x%
	Number := x , Number += 0  ; convert text to number
;MsgBox %Number%
	return %Number%
} ;/*}}}*/

decale_coupe(sens, combien)
{
; décale les y0 et ym dans le sens -1 = avant, +1 = arrière,
; de combien (1 ou 0.5) fois l'épaisseur de la coupe

; ach, il faut déclarer les variables globales:
global demi_epaisseur_coupe
global decalage
global x_icon_piscine
global y_icon_piscine
global attente_ms

;Click %x_icon_piscine%, %y_icon_piscine%
MouseClick right
Send, V
WinWaitActive, Définir Vue, 
Send, {TAB}{TAB}{TAB}
;on est maintenant rendu à Y0: il faut le décrémenter de decalage:
;on copie:
Send, {CTRLDOWN}{INS}{CTRLUP}
y0_initial := clipboard
Send, {TAB}
Send, {CTRLDOWN}{INS}{CTRLUP}
ym_initial := clipboard
decalage   := (ym_initial - y0_initial) * combien
y0_nouveau := y0_initial - decalage*sens
ym_nouveau := ym_initial - decalage*sens
;on recolle
Send, {SHIFTDOWN}{TAB}{SHIFTUP}
clipboard = %y0_nouveau%
Send, {SHIFTDOWN}{INS}{SHIFTUP}
clipboard = %ym_nouveau%
Send, {TAB}
Send, {SHIFTDOWN}{INS}{SHIFTUP}
Sleep %attente_ms%
Send, {ENTER}
return
}

enfonce_plan(sens, combien)
{
;décale les z0 et zm dans le sens -1 = bas, +1 = haut

; ach, il faut déclarer les variables globales:
global demi_epaisseur_coupe
global decalage
global x_icon_piscine
global y_icon_piscine
global attente_ms

;Click %x_icon_piscine%, %y_icon_piscine%
MouseClick right
Send, V
WinWaitActive, Définir Vue, 
Send, {TAB}{TAB}{TAB}{TAB}{TAB}
Send, {CTRLDOWN}{INS}{CTRLUP}
z0_initial := clipboard
Send, {TAB}
Send, {CTRLDOWN}{INS}{CTRLUP}
zm_initial := clipboard
decalage   := (zm_initial - z0_initial) * combien
z0_nouveau := z0_initial - decalage*sens
zm_nouveau := zm_initial - decalage*sens
;on recolle
Send, {SHIFTDOWN}{TAB}{SHIFTUP}
clipboard = %z0_nouveau%
Send, {SHIFTDOWN}{INS}{SHIFTUP}
clipboard = %zm_nouveau%
Send, {TAB}
Send, {SHIFTDOWN}{INS}{SHIFTUP}
Sleep %attente_ms%
Send, {ENTER}
return
}

;/*}}}*/
;###############################################################################














;TMP maquereau à tout fer, on la change à chaque bezoin
F12::
;un recopiage dans excel:(
;;;;Send, {DOWN}{RIGHT}{RIGHT}{CTRLDOWN}{INS}{CTRLUP}{DOWN}{LEFT}{LEFT}{SHIFTDOWN}{INS}{SHIFTUP}{DOWN}{SHIFTDOWN}{INS}{SHIFTUP}
Send, {RIGHT}{DOWN}
;Send, {DOWN}
;Send, {RIGHT}
Send, {CTRLDOWN}{INS}{CTRLUP}
Send, {RIGHT}{DOWN}
;Send, {DOWN}{LEFT}
Send, {CTRLDOWN}{SHIFTDOWN}{DOWN}{CTRLUP}{LEFT}{LEFT}{SHIFTUP}
Send, {SHIFTDOWN}{TAB}{TAB}{LEFT}{LEFT}{SHIFTUP}
Send, {ENTER}
Send, {CTRLDOWN}{DOWN}{CTRLUP}
return
;)

;F11::
;;enlève des lignes vides dans excel:
;Send, {SHIFTDOWN}{SPACE}{SHIFTUP}{CTRLDOWN}-{CTRLUP}{CTRLDOWN}{DOWN}{CTRLUP}{DOWN}
;return
;Send, {DOWN}{RIGHT}{RIGHT}{CTRLDOWN}{INS}{CTRLUP}{DOWN}{LEFT}
;{CTRLDOWN}{DOWN}{CTRLUP}

;{LEFT}{SHIFTDOWN}{INS}{SHIFTUP}{RIGHT}{CTRLDOWN}{DOWN}{CTRLUP}{LEFT}{SHIFTDOWN}{CTRLDOWN}{UP}{SHIFTUP}{CTRLUP}{ENTER}{UP}{CTRLUP}{UP}{SHIFTDOWN}{SPACE}{SHIFTUP}{CTRLDOWN}-{CTRLUP}
;{DOWN}{SHIFTDOWN}{INS}{SHIFTUP}



;###############################################################################
;###############################################################################
;###########POUBELLE##########
                        ;Sleep, 100
                        ;WinWait, D?inir Vue, 
                        ;IfWinNotActive, Définir Vue, , WinActivate, Définir Vue, 




                        ;xls recopie vers le bas sauf 1 cellule
                        ;^F10::
                        ;Send, {Control}{SHIFTDOWN}{DOWN}
                        ;Send, {SHIFTDOWN}{UP}
                        ;Sleep, 100
                        ;Send, {Control}D


                        ;Click 516,81
                        ;Send LButton
                        ;WinWaitActive
                        ;Sleep 1000
                        ;Loop 9 {
                        ;       Send Tab
                        ;}
                        ;Send +Tab
                        ;Send {Enter}
                        ;Sleep 100
                        ;return


                        ;Send Down
                        ;Sleep 10
                        ;Sleep 10
                        ;Send F8
                        ;return

;###############################################################################
;###############################################################################
;###############################################################################
