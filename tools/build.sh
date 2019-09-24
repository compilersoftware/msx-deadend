#!/usr/bin/env bash

open ~/Downloads/msx/msx.img
sleep 2
cp ~/Downloads/msx/DEADEND.BAS /Volumes/Untitled/ 
diskutil unmount /Volumes/Untitled/
cp ~/Downloads/msx/msx.img ~/Downloads/msx/msx.img.dsk

