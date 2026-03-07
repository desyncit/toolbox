#!/bin/bash -x
# cumulus-ztp: provisions cumulus linux switches  
# 
# Justin Herron jherron@net-dev.net
# Source env files 

. /etc/os-release

# Vars start
VERSION="v1.3"
DFMT="$(date "+%T")"
SSHDIR="/root/.ssh"
AT="<access-token-from-gitlab>"
LOG="/var/log/provision.log"
EMAIL="email@domain.com"

trap error ERR
exec >> $LOG 2>&1

LICENSE="license.txt"
KEYS="authorized_keys"
IMAGE="<image-version"
HSFLOWD="hsflowd.conf"

# Vars end
# functions start

do_init(){
printf "Setting base configuration for dns to work"
systemctl enable --now netd
net add time zone America/New_York
net add dns nameserver ipv4 1.1.1.1
net add dns nameserver ipv4 9.9.9.9
net add dns nameserver ipv4 10.150.2.1 vrf mgmt
net commit
}

error(){
  local addr=$(awk '{print $3}' <<< $(ip -br addr show dev eth0))

  echo "Script failed while running the command $BASH_COMMAND at line $BASH_LINENO" | mutt -s "host $HOSTNAME@${addr}" $EMAIL
  printf "Script failed while running the command $BASH_COMMAND at line $BASH_LINENO" >&2
  exit 1
}
check_rel(){
     printf "Checking release before installing license\n"
     if [ $VERSION_ID != '4.1.1' ]; then
        printf "Error release is not up to standard updating to 4.1.1\n"
        /usr/cumulus/bin/onie-install -a -i $IMAGE
        in=$?
        if [ $in -eq 0 ]; then
           printf "Rebooting!!!!!!!\n"
           init 6
        else
           exit 1
        fi
     else
        printf "Nevermind all good installing license\n"
        return 0
     fi
}
install_license(){
     printf "$DFMT INFO: Installing License...\n"
     /usr/cumulus/bin/cl-license -i $LICENSE
     r=$?
     if [ $r -eq 0 ]; then
         printf "$DFMT INFO: License Installed, restarting switchd\n"
         systemctl restart switchd
     else
         printf "$DFMT ERROR: License not installed. Return code was: $r\n"
         /usr/cumulus/bin/cl-license
         exit 1
     fi
}
authorized_keys(){
     if [ ! -d "$SSHDIR" ]; then
             printf "Creating ssh directory in $SSHDIR\n"
             mkdir $SSHDIR;
             printf "Adding NetOps keys\n"
             curl -o $SSHDIR/authorized_keys $KEYS >&2
     else
             printf "Adding NetOps keys\n"
             curl -o $SSHDIR/authorized_keys $KEYS >&2
     fi
}
base(){
 #variables
        local LEAP="https://hpiers.obspm.fr/iers/bul/bulc/ntp/leap-seconds.list"
 # arrays;
        local dservices=("ntp" "ssh" "nginx" "netqd")
	# packages: 
	#    Editors: vim,nano,vi
	#    mail:
	#         - libsasl2-modules is for authentication.
	#         - mut email client
        local packages=("vim" "nano" "vi" "mutt" "libsasl2-modules")


# setup time 
        curl -o /usr/share/zoneinfo/leap-seconds.list $LEAP
        echo "interface ignore wildcard" >> /etc/ntp.conf
        timedatectl set-timezone America/New_York
        ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
# setup repos
	echo "deb http://deb.debian.org/debian buster main" >> /etc/apt/sources.list
	echo "deb http://deb.debian.org/debian buster-updates main" >> /etc/apt/sources.list

# update package cache
        apt-get update -y 
        for p in ${packages[@]}; do 
            apt-get install -y ${p}
        done

# set up mutt
cat <<EOF > ~/.muttrc
set from = ""
set realname = "Provisioning"
set smtp_url = "/"
set smtp_pass = ""
set imap_user = ""
set imap_pass = ""
EOF

# disable services we do not want running running in default vrf
        printf "Setting up vrf related services....."
        for d in ${dservices[@]}; do 
            systemctl disable --now ${d}
        done 
# Enable mgmt vrf services
        for v in ${dservices[0]} ${dservices[1]}; do
            systemctl enable --now ${v}@mgmt
        done

# Send email advising done

echo "Base configuration for $(hostname -s) is complete" | mutt -s "ALERT!! $(hostname)@$(ip -br addr show dev eth0 | awk '{print $3}')" $EMAIL

}
# Functions end

declare do_stuff

# populate the array then off she goess 
do_stuff+=("do_init")
do_stuff+=("check_rel")
do_stuff+=("authorized_keys")
do_stuff+=("install_license")
do_stuff+=("base")

for i in ${do_stuff[@]}; do
	printf " + Starting -> ${i}\n +-\033[75b\n" 
	${i}
done

unset do_stuff

# CUMULUS-AUTOPROVISIONING

exit 0
