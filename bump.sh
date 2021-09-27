#!/bin/sh
cat ./version.txt | awk 'BEGIN { FS="." } { $3++;} { printf "%d.%d.%d\n", $1, $2, $3 }' > version.tmp
mv version.tmp version.txt
