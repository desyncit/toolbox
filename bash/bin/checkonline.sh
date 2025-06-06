#!/bin/sh
# Shell script to scan local arp cache and check online 
# Function endpoint can be used to as well to check endpoint if needed
#
# Note this requires the mtr command to be installed 
#
# MAINTAINER: jherron@redhat.com
# ===================================================
# To do: 
# - Add check to verify mtr is installed (done)
# - Add capibility to do both local subnet and external networks 
#   path check. (done - added case statement for prompt)

# Functions
check() {
	PKCHK=$(which mtr | awk -F / '{print $4}')

	if [[ $EUID -ne 0 ]]; then
        	printf "Error, this script needs superuser powers please run as root\n"
		exit 1
	elif [[ $PKCHK != "mtr" ]]; then
		read -rp "Error, package mtr not found would you like to install it? (y/n)" ANS
	
		if [[ $ANS == "y" ]]; then
			yum install mtr -y 
		elif [[ $ANS == "n" ]]; then
			exit 1
		else
			printf "exiting\n"
			exit 0
		fi		
	else
	       return 0
	fi	
}


scan(){
# Check local Arp cache looking for whats reachable or failed
ip -s -s neigh show all | awk '$1 ~ /^[0-9].+$/ {printf("ADDR->[%s] IFACE->[%s] status->[%s]\n", $1,$3, $NF)}'
}


endpoint(){

# Prompt end user for destination
	options=( "Scan local ips" "Specify Endpoint" )
		select opt in "${options[@]}"
		do
			case $opt in

			"Scan local ips")
					local retval="redhat.com"
					_cache=$(ip -s -s neigh show all | awk '$1 ~ /^[0-9].+$/ && $NF !~ /FAILED/ {print $1}')
				        echo "$retval $_cache"
					break
					;;
			"Specify Endpoint")
					read -p "Please specify and ipv4 endpoint(x.x.x.x)" DST
					echo $DST
				       	break	
					;;
			"exit")
					printf "Exiting\n"
					break
					;;
				*) 
					printf "Incorrect choice try again"
					;;
			esac
		done

}

# Variables
getval=$(endpoint)
scan=$(scan)

# Run check() for required conditions
check

# Show reachable,failed in local arp cache
printf "\n+ Found the below addresses reachable or stale in local arp cache\n+===============================================================+\n%s" "$scan"

# Cycle through ips
for x in $getval; do 
	ping -c 1 -W 1 "${x}" >/dev/null; 
	if [[  $? == 0 ]]; then 
		printf "\n Gathering Network path statistics for %s \n+==========================================================+\n" "${x}";
		echo ${x} | while read e; 
				do mtr -r -c 10 -n -o "SR LDRWBA" $e; 
			    done
	else 
		printf "\n+ No response from %s \n+========================+\n" "${x}"
	fi
done

