#!/usr/bin/bash
# * synopsis
# Make use of named pipes to write incoming binary packet data to
# then use tcpdump to read from the named pipe and filter on the collector
# host.
#  
# * Dependencies
# - ssh key login 
# - tcpdump package install on collector host and remote hosts.
# MAINTAINER: jherron@redhat.com
# ===================================================
AOPTS=":i:a:s:"
WRITE=/tmp/data
PCAPS=/tmp/data/pcaps
# set iface to metachar to allow it to be overiden
# in check()
iface=.

function sem(){
    mkfifo FIFO_$$      
    exec 3<>FIFO_$$     
    rm FIFO_$$           
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}
function lockit() {
    local x 
    read -u 3 -n 3 x && ((0==x)) || exit $x
    ( ( "$@"; ) 
    printf '%.3d' $? >&3 
    )&
}
function stopit(){
   pkill tcpdump;
   printf "Exiting....\n"
   exit 0;
}
function usage(){
   printf "%s: -a <ipaddr/hostname> -i <interface> -s <snaplen: 0-65335 bytes>\n" $0
   error  
}
function error(){
   printf "$@\n" 1>&2
   rm -rf $WRITE
   exit 1
}
function capture(){
   trap 'stopit' SIGINT
   
   local -n _ipaddr=$1 
   local    iface=$2
   local    snap=$3 
   
   N=4
   sem $N 
   for int in $iface; do
      for haddr in ${_ipaddr[@]}; do         
           mkfifo $WRITE/${haddr}
           res=$?
           if [[ $res != 0 ]]; then
               error "$@\n" 2>&1
           fi
           # Read from named pipe above, then filter on the local host
           tcpdump -nnr $WRITE/${haddr} -s $snap -w $PCAPS/${haddr}.pcap &
           # Write output of remote tcpdump command unbuffered(-U) filter out ssh into
           # the named pipe above.
           # SSH + TCPDUMP + SEMAPHORES!!!!! === AWESOME!
           lockit ssh root@${haddr} 'tcpdump -nni '"${int}"'  -U -w - not port 22' > $WRITE/${haddr}
       done
   done
   printf "Press CNTRL-C to stop\n" 
   wait 
}
function check(){
   # Whole bunch of branches
   # static var iparr reads in the array
   # but only to make sure its not empty
   local -n iparr=$1
   local    iface=$2
   local    snap=$3
   local    uint='^[0-9]+$'
   local    charuint='^[a-z0-9]+$'

   if [[ $EUID != 0 ]]; then
    printf "ERROR: please run as root\n";
    error "$@" 2>&1
    exit 1;
   fi
   if [[ ! $iface =~ $charuint ]]; then
      local iface=any
   fi
   if [[ ! $snap =~ $uint ]]; then
       snap=0;
   fi
   if [[ ! -d $PCAPS ]]; then
         mkdir -p ${PCAPS};
   fi
   # use arithmetic expansion to check 
   # the sizeof the iparr array is non-zero
   if (( ${#iparr[@]} )); then
     capture iparr $iface $snap
   else
     usage
   fi
}

function main(){

  set -euo pipefail

  local snap=0 

  while getopts "${AOPTS}" OPT; do
      case ${OPT} in
          (i)
            iface=${OPTARG}
             ;;
          (a)
            IFS=,  # Set spacing char to ',' for comma deliminated lists
            set -f # No globbing
            addr+=("$OPTARG") 
             ;;
          (s)
            snap=${OPTARG}
            ;;
          (*)
             usage
             ;;
      esac
  done
  
  # Pass entire named array into check() 
  # function and do not expand the named array
  check addr $iface $snap
}
# call main and pass all opts and args to main, then off she goes
# c-style int main(int argc, char **argv)
main $@
