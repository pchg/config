#!/bin/sh
pdf2ps "$1" /tmp/"$1.ps"
ps2pdf /tmp/"$1.ps" "$1_slim.pdf"

