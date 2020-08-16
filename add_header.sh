#!/bin/bash

for x in *; do
    cat $HOME/Projects/header.txt $x > $x.tmp
    mv $x.tmp $x
done
