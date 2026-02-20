#!/bin/bash

# Variables

SHELLSCRIPTS=`ls *.sh`

	echo "List all of shell script contents in the pwd"

	echo "Listings:"
	echo "==================="
	echo "$SHELLSCRIPTS" | nl

for SCRIPT in "$SHELLSCRIPTS"; do
	DISPLAY="`cat $SCRIPT`"
	   echo "============================"
	   echo "Files:"
	   echo "============================"
	   echo "$SCRIPT"
	   echo "============================"
	   echo "Contents are displayed below"
	   echo "============================"
	   echo "$DISPLAY " | nl 
done