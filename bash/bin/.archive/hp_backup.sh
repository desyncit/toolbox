#!/bin/bash
# Uses FIFO-Based semaphores to multi-thread this script "technically".
#
# see [SCP/SFTP operating notes]
# (https://techhub.hpe.com/eginfolib/networking/docs/switches/K-KA-KB/15-18/5998-8160_ssw_mcg/content/ch10s02.html)
# for directory structure on hp procurves variables

# Varible start
BACKUPDIR="/path/to/git/repo"
RSWICONF="/cfg/running-config"
STRCONF="/cfg/startup-config"
NULL="/dev/null"
COUNT=50
# Variable end

# Arrays
hpstack+=("switchone")
hpstack+=("switchtwo")
# Arrays end


# functions start

# Disclaimer about the sem() and lockit() functions, 
# basically using FIFO-based semaphores to make this 
# script multi-threaded.

# This approach speed up processing speed up execution 
# time significantly on a fleet of about
# fifty switches from ~3min to ~30sec plus or minus a 
# few seconds. 

# Be sure to become somewhat familiar with semaphores
# as you can definetly trip over and fall on your 
# face with them. 

function sem(){
    mkfifo pipe-$$      
    exec 3<>pipe-$$     
    rm pipe-$$           
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}
function lockit() {
    # used to lock the thread and prevent any process from entering 
    local x 
    read -u 3 -n 3 x && ((0==x)) || exit $x
    ( ( "$@"; ) 
    printf '%.3d' $? >&3 
    )&
}
function usage() {
         printf "USAGE: ./hp_backup -[a|s|h] \n
                 -h help \n
                 -s <hostname> backup single host \n
                 -a backup all hosts\n"
         exit 1
}
function error() {
  echo -e "\e[0;33mERROR: Backup failed while runnning the command $BASH_COMMAND at line $BASH_LINENO.\e[0m"
  exit 1
}
function all(){
        # need this line for hp procurves
        local ARGS="-i ~/.ssh/<identity-key> -o KexAlgorithms=+diffie-hellman-group1-sha1 -o Ciphers=+3des-cbc" 
        N=4
        sem $N   # Call sem() for 4 "threads" 
        for host in ${hpstack[@]}; do
                 # then pass $1 into lockit for exec.
                 lockit /usr/bin/scp $ARGS ${host}:$RSWICONF $BACKUPDIR/${host}/${host}.conf #&> /dev/null
                 printf "Host: ${host} completed\n"
        done
}
function single(){
  local host=$1
        if [[ -z ${host} ]]; then
                usage;
        fi
        printf "Grabbing configuration for host: ${host}\n-\033[%db\n" ${COUNT}
        /usr/bin/scp $host:$RSWICONF $BACKUPDIR/$host &> $NULL
        printf "Completd for ${host}\n"
}
trap error ERR

if [[ -z $1 ]]; then
        usage
fi

while getopts :h:s:a argv
	do
        	case "${argv}" in
	                a) all;;
	                s) single ${OPTARG};;
	                h) usage;;
	                *) usage;;
	        esac
	done

