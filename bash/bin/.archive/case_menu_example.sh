#!/bin/bash

# Script for simple menu example

echo "Menu for choice"
echo "+++++++++++++++"
echo "1) Option 1"
echo "2) Option 2"
echo "3) Option 3"
echo "4) Option 4"
echo "5) exit"
echo " "
echo "What option would you like?"
read CHOICE

case $CHOICE in
        1)
	 echo "Option 1"
	 ;;
	2)
	 echo "Option 2"
	 ;;
	3)
	 echo "Option 3"
	 ;;
	4)
	 echo "Option 4"
	 ;;
	5)
	 echo "Exiting "
	 ;;
	*) echo "Invalid option Please pick from the Menu"
	 ;;
esac
