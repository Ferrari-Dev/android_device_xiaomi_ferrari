#!/bin/sh

MYABSPATH=$(readlink -f "$0")
PATCHBASE=$(dirname "$MYABSPATH")
CMBASE=$(readlink -f "$PATCHBASE/../../../../")

for i in $(find "$PATCHBASE"/* -type d); do
	PATCHNAME=$(basename "$i")
	PATCHTARGET=$PATCHNAME
	for i in $(seq 4); do
		PATCHTARGET=$(echo $PATCHTARGET | sed 's/_/\//')
		if [ -d "$CMBASE/$PATCHTARGET" ]; then break; fi
	done
	cd "$CMBASE/$PATCHTARGET" || exit 1
	files=$( ls -r "$PATCHBASE/$PATCHNAME"/* )
	for file in $files; do
		patch=${file#*"$PATCHBASE/$PATCHNAME/"}
		echo -n "reverting $PATCHNAME: $patch > "
		git -c core.fileMode=false apply -R --3way $file
		if [ $? -ne 0 ]; then
			echo "failed"
			exit 1
		fi
		echo "ok"
	done
done
