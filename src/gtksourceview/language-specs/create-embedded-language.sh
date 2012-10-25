#!/bin/sh

# $1: language-spec filepath

LANG=$(basename $1)
VARPART=$(echo $LANG | sed 's|\.|_|g')
VAR="embedded_$VARPART"

echo -n "const char* $VAR = "
sed -e 's|\\|\\\\|g' -e 's|"|\\"|g' -e 's|^\(.*\)$|"\1\\n"|' $1
echo '"";'
