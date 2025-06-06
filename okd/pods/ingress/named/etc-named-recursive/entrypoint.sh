#!/bin/bash

function errno(){
	local argv=("$1");

	case ${argv[0]} in
		"1")
	          printf "OOps check config\n"
		  exit 1
		  ;;
		 "2")
	          printf "Opps forward zone\n"
		  exit 2
		  ;;
	  	 "3")
                  printf "Opps rev zone\n"
                  exit 3
                  ;; 
                 "4")
                  printf "Opps forward zone\n"
                  exit 4
                  ;;
        esac

  unset argv
  return 0
}
	

function _precommit(){ 
  printf "Checking conf before commit\n"
  /usr/sbin/named-checkconf /etc/named.conf
  ret=$?
  (( ! ${ret} > 0 )) || errno 1

  return 0
}

function zoneforward(){
    printf "Checking forward zone\n"
    /usr/sbin/named-checkzone ${FORDOM} /var/named/db.${FORDOM}
    ret=$?
    (( ! ${ret} > 0 )) || errno 2 

  return 0
}

function zonerev(){
	printf "Checking reverse zone\n"
        /usr/sbin/named-checkzone ${REVDOM} /var/named/db.${REVDOM}
        ret=$?
        (( ! ${ret} > 0 )) || errno 3
        return 0
}

function hints(){
  local _hints="https://www.internic.net/domain/named.root"
  local _out_hints="/var/named/db.root."
  
  curl -vvv ${_hints} --output ${_out_hints} --write-out "%{http_code}"

  printf "Checking size is not zero for db.root.\n"
  
  [[ -s ${_out_hints} ]] || errno 4

  return 0
}

function dns(){
	printf "starting named"
        /usr/sbin/named -g -4 -u named -c /etc/named.conf; 
        return 0
}


function main(){
	declare _fns
       	printf "Running checks on named\n"
	zoneforward
	zonerev
	hints
	_precommit
        dns
  return 0
}

main
