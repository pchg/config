#!/usr/bin/rebol
REBOL [Title: "Binary Resource Embedder *** SAVE THIS PROGRAM ***"]
system/options/binary-base: 64
editor picture: compress to-string read/binary to-file request-file/only

