# header file for audio functions
function streamaudio(){
	PS3='What place would you like to listen to? '
	options=("Home" "Record" "Quit")
	select opt in "${options[@]}"
	do
        case $opt in
                   "Home")
                        # hw:2,0 refers to the hardware location of the microphone
                        ssh $user@$node ffmpeg -f alsa -ac 2 -i hw:2,0 -f ogg - | mplayer - -idle
                        ;;
                 "Record")
                        echo -n "Recording now"
                        sleep 1
                        ffmpeg -nostdin -nostats -f alsa -ac 2 -i hw:2,0 -f ogg - | mplayer -dumpstream -dumpfile /tmp/$(hostname)
                        ;;
                   "Quit")
                        echo -e "exiting"
                        sleep 1
                        break
                        ;;
                        *) echo "Invalid option $REPLY"
                        ;;
        	esac
	done

return 0
}
