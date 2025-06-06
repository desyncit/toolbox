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

endpoint(){
local DST=""
read -p "Please specify and ipv4 endpoint(x.x.x.x)" DST

    printf "\n+ Found the below addresses reachable or stale in local arp cache\n+\n%s" "$s"
   for x in ${getval}; do 
        ping -c 1 -W 1 "${x}" >/dev/null; 
        ret=$?;

	(( ! ${ret} )) || printf "\n+ No response from %s \n" "${x}";
   	
        echo ${x} | while read e; do mtr -r -c 10 -n -o "SR LDRWBA" ${e}; done
   done


return 0
}

localips(){
local _s=$(awk '$1 ~ /^[0-9].+$/ {printf("ADDR->[%s] IFACE->[%s] status->[%s]\n", $1,$3, $NF)}' <<< $(ip neigh show all) )
local _cache=$(awk '$1 ~ /^[0-9].+$/ && $NF !~ /FAILED/ {print $1}' <<< $( ip neigh show all ) )

  printf "\n+ Rreachable or stale addresses in local arp cache\n+\n%s" ${_s}

  return 0
}




main(){ 

local argv=("$@")
local argc=("$#")
local _default_endpoint="redhat.com"

local options=( "Scan local ips" "Specify Endpoint" )

      select opt in "${options[@]}"
      do
        case $opt in
          "Scan local ips")
            break
          ;;
          "Specific Endpoint")
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

   return 0
} 

main $@
