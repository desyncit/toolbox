#!/bin/bash

. /var/git/desyncit/toolbox/bash/include/s3errno.sh

function getnooba(){
   local ARCH=amd64
   local OS="linux"
   local VERSION=$(curl -s https://api.github.com/repos/noobaa/noobaa-operator/releases/latest | jq -r '.name')
   local LINK=$(https://github.com/noobaa/noobaa-operator/releases/download/$VERSION/noobaa-operator-$VERSION-$OS-$ARCH.tar.gz)
   local tarball="noobaa-operator-$VERSION-$OS-$ARCH.tar.gz"

   curl -LO ${LINK} && tar -C ${_install_path} --transform=s/noobaa-operator/noobaa/ -xf ${tarball} ./noobaa-operator

   return 0
}

function go_get_go(){
   GOPATH=${_install_path}
   $pkg_manager $pkg_manager_args go

   (( ! ${#GOPATH} != 13 ? 1 : 0 )) || mkdir $GOPATH

   echo "export GOPATH=${GOPATH}/go" | tee /etc/profile.d/golang.sh
   echo   'export PATH=$GOPATH:$PATH' | tee -a /etc/profile.d/golang.sh

   . /etc/profile.d/golang.sh

   GOBIN=${GOPATH} go install github.com/peak/s5cmd/v2@v2.2.2

   main
   return 0
}

function get_aws(){
   local link="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
   local link_out="/tmp/awscliv2.zip"
   local _install_path="/tmp/aws/install"

   for pck in wget curl unzip; do
         $pkg_manager $pkg_manager_args ${pck[@]};
   done
   unset pck

   curl  ${link} -o ${stage} && unzip -o /tmp/awscliv2.zip || error 255
   bash -x ${install} --bin-dir ${_install_path} --install-dir ${_install_path}/aws-cli --update;
   cp -r ${0%/*}/auth/aws $HOME/.aws
   
   main
   return 0
}

function get_s3cmd(){
  $pkg_manager $pkg_manager_args s3cmd
  ret=$?
  (( ! ${ret} )) || exit 1

  return 0
}

function os_detect(){
  . /etc/os-release
  
  case ${ID} in
        arch)
  	  pkg_manager="pacman"
  	  pkg_manager_args="-Sy --noconfirm --needed"
          _install_path="/usr/local/bin"
  	;;
  	rhel)
   	  pkg_manager="dnf"
	  pkg_manager_args="install --assumeyes"
          _install_path="/usr/local/bin"
	;;
	*)
	  error 6
 	;;
    esac
  return 0
}

function checks(){
  local argc=("$#")
  local argv=("$@")

  declare -a foo
  local ret=0;
 
  local gobin=$( which go )
  local awsbin=$( which aws )
  local s3cmdbin=$( which s3cmd )
  local noobaabin=$( which noobaa )

  os_detect

  foo+=(" $(( ! ${EUID} ? 0 : 1 )) ")
  foo+=(" $(( ${#argc} > 2 ? 2 : 0 )) ")
  foo+=(" $(( ${#gobin} > 0 ? 0 : 3 )) ")
  foo+=(" $(( ${#awsbin} > 0 ? 0 : 4 )) ")
  foo+=(" $(( ${#s3cmdbin} > 0 ? 0 : 5 )) ")

  for ret in ${foo[@]}; do
    if [[ $ret != 0 ]]; then
       error $ret;
    fi
  done
  unset foo ret argc argv gobin awsbin
}

function main(){
   set -euo pipefail

   checks
   return 0
}

main $@
