#!/bin/sh

MYABSPATH=$(readlink -f "$0")
PATCHBASE=$(dirname "$MYABSPATH")
CMBASE=$(readlink -f "$PATCHBASE/../../../../")

echo "running $0"

for i in $(find "$PATCHBASE"/* -type d); do
	PATCHNAME=$(basename "$i")
	PATCHTARGET=$PATCHNAME
	for i in $(seq 4); do
		PATCHTARGET=$(echo $PATCHTARGET | sed 's/_/\//')
		if [ -d "$CMBASE/$PATCHTARGET" ]; then break; fi
	done
	cd "$CMBASE/$PATCHTARGET" || exit 1
	for file in "$PATCHBASE/$PATCHNAME"/*
	do
		patch=${file#*"$PATCHBASE/$PATCHNAME/"}
		echo -n "patching $PATCHNAME: $patch > "
		git -c core.fileMode=false apply --check $file
		if [ $? -ne 0 ]; then
			echo "failed"
			exit 1
		fi
		git -c core.fileMode=false apply --3way $file > /dev/null 2>&1
		if [ $? -ne 0 ]; then # should never get here
			echo "failed"
			exit 1
		fi
		echo "ok"
	done
done
