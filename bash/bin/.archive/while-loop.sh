#!/bin/bash

# While loop example

echo "Enter the number of times to display the word 'Bitch'."
read NUMBER

n=1

while [ $n -le $NUMBER ]
	do
	  echo "Bitch - $n"
	  n="`expr $n + 1`"
done