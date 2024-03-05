#!/bin/bash

# Bascule la visibilité des bordures de la fenêtre courante:
icesh -f if -P _NET_FRAME_EXTENTS=0 then bordered else borderless

