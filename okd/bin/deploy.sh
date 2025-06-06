#!/bin/bash

function _setup(){
  local c="--connect qemu+ssh://$1/system"
  local n="$2"

  virsh ${c} destroy ${n}
  virsh ${c} undefine ${n}
  virsh ${c} pool-refresh --pool default
  virsh ${c} vol-delete --pool default ${n}
  virsh ${c} vol-create-as default --name ${n} --capacity 100G --format raw

  unset c n
  return 0
}

function bootstrap(){
   local nodename=$FUNCNAME
   local hypervisor=$virt_hostname
   local role=$FUNCNAME
   local ram="16192"
   local vcpu="8"
   local clusterdir="/etc/containers/okd/4/cluster"
   local coreosdir="/etc/containers/okd/4/coreos"
   local installconfig="/etc/containers/okd/4/configs/install-config.yaml"
  
   # since we are calling bootstrap, we are reseting
   for h in vtx0{1..2}; 
   do
     awk '!/^$/{print $1}' <<< $(virsh -c qemu+ssh://${h}/system list --all --name) | while read domain;
     do
	_setup ${h} ${domain}
     done
   done  
   
   printf "Scrubing host-key from know_hosts\n"
   { 
     for i in {10,11,20,21,30,31}; do
         ssh-keygen -R 1.1.${i};
     done; 
   } 2>&1 > /dev/null

   rm -rf ${clusterdir} && mkdir ${clusterdir} && cp ${installconfig} ${clusterdir}
   openshift-install create manifests --dir=${clusterdir} 
   sed -i 's/mastersSchedulable: true/mastersSchedulable: false/' ${clusterdir}/manifests/cluster-scheduler-02-config.yml
   openshift-install create ignition-configs --dir=${clusterdir}

   # sync ignition files
   s5cmd --stat cp --acl public-read "/etc/containers/okd/4/cluster/*.ign" s3://okd/ignition/
  
   # sync coreos files
   s5cmd --stat cp -u --acl public-read $coreosdir/ s3://okd/coreos/

   deploy $nodename 
}

function master(){
   local nodename="$1"
   local hypervisor=$2
   local role=$FUNCNAME

   local ram="32384"
   local vcpu="8"

   deploy $nodename 
   return 0
}

function worker(){
   local nodename="$1"
   local hypervisor=$2

   local role=$FUNCNAME
   local ram="32384"
   local vcpu="8"

   deploy $nodename
   return 0
}

function deploy(){ 

  local cluster_domain=""
  local ip=${okd_domain_addr:-"0"}
  local ignition_url="https://1.1.1.1" 
  local ipstatic="ip=${ip}::1.1.1.1:255.255.255.0:${nodename}.${cluster_domain}:enp1s0:none nameserver=1.1.1.1 nameserver=1.1.1.1"
  local ignition="coreos.inst.ignition_url=${ignition_url}/okd/ignition/${role}.ign"
  local rootfs="${ignition_url}/okd/coreos/39/fedora-coreos-39.20240225.3.0-live-rootfs.x86_64.img"
  local k="${ignition_url}/okd/coreos/39/fedora-coreos-39.20240225.3.0-live-kernel-x86_64"
  local i="${ignition_url}/okd/coreos/39/fedora-coreos-39.20240225.3.0-live-initramfs.x86_64.img"
  local kargs="coreos.live.rootfs_url=${rootfs} rd.neednet=1 coreos.inst.install_dev=/dev/vda"
  

  _setup $virt_hostname $nodename

virt-install \
--connect qemu+ssh://${virt_hostname}/system \
--name ${nodename} \
--virt-type kvm \
--ram ${ram} \
--vcpu ${vcpu} \
--os-variant fedora-coreos-stable \
--disk vol=default/${nodename},device=disk,bus=virtio,format=raw \
--noautoconsole \
--vnc \
--network network=default \
--boot hd,network \
--install kernel=${k},initrd=${i},kernel_args_overwrite=yes,kernel_args="${kargs} ${ipstatic} ${ignition}"

return 0
}

function main(){
   local okd_type=""
   local okd_nodename=""
   local okd_domain_addr=""
   local virt_hostname=""

   local -i argc=$#
   (( ! ( ${argc} <= 0 ) && ! ( ${argc} != 8 )  )) || { printf "Not enought args passed\n" && exit 1; }

   while getopts "t:d:n:a:" args; do
	   case $args in
		   (t)
		   # type of domain for the cluster i.e. compute or control
	            okd_type=${OPTARG}
		   ;;
		   (d)
		    # name of the domain 
		    okd_nodename=${OPTARG}
		   ;;
 	           (n)
                    # name of hypervisor we are installing on
		    virt_hostname=${OPTARG}
		   ;;
                   (a)
  		    # address of the domain
                    okd_domain_addr=${OPTARG}
                   ;;
	           (*)
	            printf "input invalid\n"
		    exit 1
        	   ;;  
	   esac
   done
   printf "Installing a %s virtual machine on %s named %s with address %s\n" $okd_type $virt_hostname $okd_nodename $okd_domain_addr
   eval "$okd_type $okd_nodename $okd_domain_addr $virt_hostname"
return 
}

main $@	
