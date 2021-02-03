#!/bin/bash

for i in `cat list-of-nix-files-to-copy.txt`; do
    cp $i /etc/nixos/$i
done
