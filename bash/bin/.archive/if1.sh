#!/bin/bash
read -p "word 1: " word1
read -p "word 2: " word2

if test "$word1" = "$word2"
	then
	   echo "Match"
else
	echo "Sorry but these words did not match"
fi
echo "End of Program"
