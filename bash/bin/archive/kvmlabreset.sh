#!/bin/bash
# better version of the KVM lab reset
# Typically a fast way to get this setup is build the VMs to the desired specs via xml or with the gui virt-manager
# once the vms are built, then "virsh dumpxml <domain> > filename.xml", once this is done copy over the qcow2 files to the
# path for restore purpose. Adjust the file paths below as needed but make sure to leave the -p as well as 
# ensuring the group permissions are set to qemu and rw for the group bits.

# -rw-r--r--. 1 qemu qemu


printf 'What VM would you like to restore?\n'
options=( "node01" "node02" "ipa-server" "nevermind" )
  select opt in "${options[@]}"
                do
                case $opt in
                        "node01")
                                printf 'Restoring node01\n'
                                        cp -p /media/Repo/virtual/templates/node01/node01.qcow2 /media/Repo/virtual/volumes/
                                        cp -p /media/Repo/virtual/templates/node01/data-1.qcow2 /media/Repo/virtual/storage/
                                        virsh create /media/Repo/virtual/templates/xmls/node01.xml
                                        # This line makes the VM Persistent
                                        virsh define /media/Repo/virtual/templates/xmls/node01.xml
                                printf 'node01 has been restored\n'
                                ;;
                        "node02")
                                printf 'Restoring node02\n'
                                        cp -p /media/Repo/virtual/templates/node02/node02.qcow2 /media/Repo/virtual/volumes/
                                        cp -p /media/Repo/virtual/templates/node02/data-2.qcow2 /media/Repo/virtual/storage/
                                        virsh create /media/Repo/virtual/templates/xmls/node02.xml
                                        virsh define /media/Repo/virtual/templates/xmls/node02.xml
                                printf 'node02 has been restored\n'
                                ;;
                        "ipa-server")
                                printf 'Restoring the ipa-server\n'
                                        cp -p /media/Repo/virtual/templates/ipa-server/ipa-server.qcow2 /media/Repo/virtual/volumes/
                                        cp -p /media/Repo/virtual/templates/ipa-server/ipa-data-0.qcow2  /media/Repo/virtual/storage/
                                        virsh create /media/Repo/virtual/templates/xmls/ipa-server.xml
                                        virsh define /media/Repo/virtual/templates/xmls/ipa-server.xml
                                printf 'node03 has been restored\n'
                                ;;
                        "nevermind")
                                printf  'Well okay then\n'
                                break
                                ;;
                        *) printf 'wrong\n'
                        ;;
        esac
done
