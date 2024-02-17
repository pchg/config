#!/bin/bash

echo "Paste here the stack trace given by Python interpreter, Ctrl-D to terminate:"
read input_python_stack_trace <--EOF

echo "kk${input_python_stack_trace}kk"
while read bidule
grep "^   File \""
sed 's/^   File \"//g'
cut -d "," -f 1
cut -d "," -f 2

