#!/bin/bash

INTERVAL="1"  # update interval in seconds

if [ -z "$1" ]; then
	echo
	echo usage: $0 [network-interface]
	echo
	echo e.g. $0 eth0
	echo
	exit
fi

IF=$1

while true
do
	R1=`cat /sys/class/net/$1/statistics/rx_bytes`
	T1=`cat /sys/class/net/$1/statistics/tx_bytes`
	sleep $INTERVAL
	R2=`cat /sys/class/net/$1/statistics/rx_bytes`
	T2=`cat /sys/class/net/$1/statistics/tx_bytes`
	TBPS=`expr \( $T2 - $T1 \) \* 8 / 1000 / $INTERVAL`
	RBPS=`expr \( $R2 - $R1 \) \* 8 / 1000 / $INTERVAL`
	[ "$TBPS" -eq 0 -a "$RBPS" -eq 0 ] && continue
	 printf "$(date "+%F T%R:%S.%N") -> TX $1: $TBPS kbit/s\n\t\t\t\t  RX $1: $RBPS kbit/s\n"
done
