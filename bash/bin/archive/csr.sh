#!/bin/bash
# Written by Justin Herron
# Synopsis
#
# This script is used to: 
# (1) Create a certificate signing request to send to an authority (i.e, geotrust, COMMOD, etc) to obtain a signed certificate (.crt). 
#     It can also be used to assign and configure an interface with an additional IP.
#
# Functions declaration

online() {
	ping -c 1 $IP_ADDR 2>/dev/null 1>/dev/null
	if [ "$?" = 0 ]; then
	   echo -e -n "\e[0;31m Looks like that ip is in use or is not valid pick another one"
		exit 1
	else
	   echo -e -n "\e[0;31m Configuring interface and restarting network, don't worry you are fine."
			nmcli con mod em1 +ipv4.addresses $IP_ADDR
			nmcli con reload em1
			systemctl restart network
   	   echo -e -n "\e[0;31m Please make sure you let someone know what the ip address is that you chose so they are able to update the WebJaguar IP Matrix!!!!"
		exit 0
	fi
}
# Functions declaration end
#
# Script for menu
#
echo "Generate the CSR first via selecting domain (1) and then assign an ip if needed."
echo  "Please select from the menu what you would like to do?"

options=( "Domain" "Dedicated IP" "Quit" )
	select opt in "${options[@]}"
		do
# Case menu
			case $opt in
# Menu Option 1
				  "Domain")
						echo "What is the name of the domain?"
						    read DOMAIN
							    if [ -z $DOMAIN ]; then
								    echo "You didnt input anything??"
				   			    else
								    echo "Generating CSR for $DOMAIN"
									mkdir -p /etc/pki/tls/certs/$DOMAIN/2019/
									cd /etc/pki/tls/certs/$DOMAIN/2019/
									openssl req -out $DOMAIN.csr -new -newkey rsa:4096 -nodes -keyout $DOMAIN.key
								    echo "Csr and Key file created /etc/pki/tls/certs/$DOMAIN/2019/"
								    echo "Please just provide the contents of the csr file to WebJaguar"
							    fi
							;;
# Menu Option 2

		  		  "Dedicated IP")
						read -p  "Enter IP address": IP_ADDR
						if [ -z $IP_ADDR ]; then
							echo "You didn't input anything"
						else
							online
						fi
							;;
# Menu Option 3
				  "Quit")
						echo -e "exiting"
						break
						;;
# end
					   *) echo "Wrong"
					;;
				esac
		done
