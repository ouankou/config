#!/bin/bash

for x in *; do
    tail -n +8 <"$x" >"$x.tmp"
    mv "$x.tmp" "$x"
done
