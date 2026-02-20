#!/bin/bash

function debian {
        echo starting debian openmanage install
        cp /etc/apt/sources.list /etc/apt/sources.list.omsa
        echo "deb http://mirrors.hostwaydcs.com/linux/dell-omsa dell sara" >> /etc/apt/sources.list
        wget -O - http://mirrors.hostwaydcs.com/linux/dell-omsa/debian_sara.asc | apt-key add -
        apt-get update
        apt-get -y install dellomsa
        cp /etc/apt/sources.list.omsa /etc/apt/sources.list

        }

function redhat {
        echo starting redhat openmanage install
        wget -q -O - http://linux.dell.com/repo/hardware/latest/bootstrap.cgi | bash
        yum install srvadmin-all
        }

function oldredhat {
        echo starting legacy redhat openmanage install
        wget -q -O - http://linux.dell.com/repo/hardware/latest/bootstrap.cgi | bash
        up2date -i srvadmin-all
        }


case $1 in
	"debian")
        debian
	;;
	"redhat")
        redhat
	;;
	"oldredhat")
        oldredhat
        ;;

esac

