#!/bin/bash
# Script to lanch cameras 
# 
# Have fun with it!
# This script is used to an ARMCREST DVR 
# Your mileage may vary, depending on the dvr used
# Check to make sure the rtsp port 554 is open on the dvr
# bash_scripts]$ nmap -Pn x.x.x.x
# 
# Starting Nmap 6.40 ( http://nmap.org ) at 2020-11-26 09:30 EST
# Nmap scan report for watch.irinet.net (x.x.x.x)
# Host is up (0.0011s latency).
# Not shown: 998 closed ports
# PORT    STATE SERVICE
# 80/tcp  open  http
# 554/tcp open  rtsp


if [[ $EUID == 0 ]]; then
   printf "Do not run as root!!!\n"
   exit 1
fi

DATE=$(date "+%F_"TZ"_%Z_%H_%I_%S")
USAGE=$(cat <<-EOM
Usage: cameras [-w -p -g -y -a]
	-w -> Camera one: Driveway
	-p -> Camera two: Front porch
	-g -> Camera three: Back gate
	-y -> Camera four:  Back yard
	-a -> All Cameras (Writes to mkv file in PWD) 
EOM
)
DVRUSER="<insert username on the dvr>"
PASS="<guess what goes here>"
CAM="<insert DVR address here>"

	while getopts ':wpgyar' OPT;do 
		case "$OPT" in 
			"w")
		           printf "\nOpening Camera one: Driveway\n"
			   vlc "rtsp://$DVRUSER:$PASS@$CAM/cam/realmonitor?channel=1&subtype=0" 2>/dev/null
	  		   ;;
			"p")
			   printf "\nOpening Camera two: Front Porch\n"
			   vlc "rtsp://$DVRUSER:$PASS@$CAM/cam/realmonitor?channel=2&subtype=0" 2>/dev/null
			   ;;
			"g")	
			   printf "\nOpening Camera three: Back gate\n"
	  		   vlc "rtsp://$DVRUSER:$PASS@$CAM/cam/realmonitor?channel=3&subtype=0" 2>/dev/null
			   ;;
			"y")
			   printf "\nOpening Camera Four: Back Yard\n"
			   vlc "rtsp://$DVRUSER:$PASS@$CAM/cam/realmonitor?channel=4&subtype=0" 2>/dev/null
			   ;;
			"r")
			   printf "\nOpening all and recording to $PWD/output.mkv\n"
			   ffmpeg -i "rtsp://$DVRUSER:$PASS@$CAM/cam/realmonitor?channel=1&subtype=0" \
				  -i "rtsp://$DVRUSER:$PASS@$CAM/cam/realmonitor?channel=2&subtype=0" \
				  -i "rtsp://$DVRUSER:$PASS@$CAM/cam/realmonitor?channel=3&subtype=0" \
				  -i "rtsp://$DVRUSER:$PASS@$CAM/cam/realmonitor?channel=4&subtype=0" \
				  -filter_complex "nullsrc=size=640x480 [base];
				   [0:v] setpts=PTS-STARTPTS, scale=320x240 [upperleft];
			           [1:v] setpts=PTS-STARTPTS, scale=320x240 [upperright];
				   [2:v] setpts=PTS-STARTPTS, scale=320x240 [lowerleft];
				   [3:v] setpts=PTS-STARTPTS, scale=320x240 [lowerright]; 
				   [base][upperleft] overlay=shortest=1 [tmp1];
				   [tmp1][upperright] overlay=shortest=1:x=320 [tmp2];
				   [tmp2][lowerleft] overlay=shortest=1:y=240 [tmp3];
				   [tmp3][lowerright] overlay=shortest=1:x=320:y=240" -c:v libx264 ${DATE}-feed.mkv
			   # This is going to make them udp socket buffers reallly really really hurt, like they may be hungover after this 
			   # is used.
			   ;`;
			"a")
			    for st in 1 2 3 4; do 
				printf "Opening channel ${st}\n"
				vlc "rtsp://$DVRUSER:$PASS@$CAM/cam/realmonitor?channel=${st}&subtype=0" 2>/dev/null; 
			     done
			  ;;
			 ?)
			  	printf "$USAGE"
                                printf "\ninvaid option -${OPTARG}\n"
  		 	  ;;
		esac
	done

if [[ -z "$1" ]]; then
	printf "\nNo args passed, exiting\n"
	printf "$USAGE\n"
	exit
if

unset DVRUSER PASS 
