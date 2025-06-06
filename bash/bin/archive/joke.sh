#!/bin/bash
sp="/-\|"
sc=0
spin() {
   printf "\b${sp:sc++:1}"
   ((sc==${#sp})) && sc=0
}
endspin() {
   printf "\r%s\n" "$@"
}

joke=0

printf "Downloading Virsus\n"

	
	until [[ $joke -eq 10 ]]; do
	spin
		for n in $(seq 1 10); do 
			sleep ${n}
			printf "Part ${n} of payload delivered\n"
		(( joke++ ))
				
	done	
done

printf "\nhahahahahahaha Just kidding :p\n"
endspin
