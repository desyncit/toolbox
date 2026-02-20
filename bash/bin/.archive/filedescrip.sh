#!/bin/bash
# demo of reading and writing to a file descriptor

echo "Enter a file name to read "
read FILE

# Set a file descript for read write
# use < to read
# use > to write
exec 5<>$FILE
# set a variable name above i.e FILE

# WHILE LOOP
while read -r USERS; do
    echo "User name: $USERS"
done <&5

# block to use for writing to the file saying it was accessed.
	echo "File was read on: `date` by $USER" >&5
exec 5>&-
