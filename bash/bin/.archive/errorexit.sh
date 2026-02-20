#!/bin/bash
# Demo for using error handling

#echo "Change to a directory and list the contents"
DIRECTORY=$1

cd $DIRECTORY 2>/dev/null

if [ "$?" = "0" ];then
    echo "We can change into the $DIRECTORY, and here are the contents"
    echo "`ls -al`"
else
   echo "Cannot change $1, exiting with error of course, does the path $1 exsist?"
   exit 1
fi
