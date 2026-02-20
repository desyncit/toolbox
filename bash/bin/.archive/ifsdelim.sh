#!/bin/bash
# delimiter example using ifs

echo "Enter filename to parse: "
read FILE

echo "Enter the Delimeter: "
read DELIM

IFS="$DELIM"

while read -r C M D; do
    echo "CPU: $C"
    echo "Memory: $M"
    echo "Disk: $D"
done < "$FILE"
