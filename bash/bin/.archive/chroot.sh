#!/bin/bash

TARGETDIR="/mnt/chroot"

mount -t proc proc $TARGETDIR/proc
mount -t sysfs sysfs $TARGETDIR/sys
mount -t devtmpfs devtmpfs $TARGETDIR/dev
mount -t tmpfs tmpfs $TARGETDIR/dev/shm
mount -t devpts devpts $TARGETDIR/dev/pts

/bin/cp -f /etc/hosts $TARGETDIR/etc/
/bin/cp -f /etc/resolv.conf $TARGETDIR/etc/resolv.conf
chroot $TARGETDIR rm /etc/mtab 2> /dev/null 
chroot $TARGETDIR ln -s /proc/mounts /etc/mtab

