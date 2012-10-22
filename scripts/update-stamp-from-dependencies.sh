#!/bin/sh
STAMPFILE="$1"
if test -z "$STAMPFILE"; then
	echo No stampfile specified.
	exit 1
fi
if ! test -f "$STAMPFILE"; then
	touch $STAMPFILE
	exit 0
fi
STAMPTIME=`stat -c %Y "$STAMPFILE"`
shift
while test -n "$1"; do
	OTHERTIME=`stat -c %Y "$1"`
	if test "$OTHERTIME" -gt "$STAMPTIME"; then
		touch $STAMPFILE
		exit 0
	fi
	shift
done
