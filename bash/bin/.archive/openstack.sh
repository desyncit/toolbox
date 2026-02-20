#!/bin/bash
# Just a script to access openstack nodes easily

# Variables for menu script
router="ssh -p 65336 user@router.network.com"
node01="ssh user@node01.network.com"
node02="ssh user@node02.network.com"
node03="ssh user@node03.network.com"
node04="ssh user@node04.network.com"

echo "Openstack Administrator Menu"
echo "please pick the node you would like to connect to"

# Configuration for Menu
options=("router" "node01" "node02" "node03" "node04" "Quit")
select opt in "${options[@]}"
do
	case $opt in
        	   "router")
		    	$router
			;;
		   "node01")
		    	$node01
		        ;;
		   "node02")
		    	$node02
		        ;;
		   "node03")
		    	$node03
	     	        ;;
		   "node04")
	 	    	$node04
		        ;;
	            "Quit")
	  		echo -e "exiting"
		        break
			;;
		*) echo "Invalid option $REPLY"
		;;
	esac
done
