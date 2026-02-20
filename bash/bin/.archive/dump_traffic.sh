set -x
if [[ $@ =~ -i[[:space:]]?[^[:space:]]+ ]]; then
    tcpdump -l $@ | sed 's/^/[Interface:'"${BASH_REMATCH[0]:2}"'] /' &
else
    for interface in $(ifconfig | grep '^[a-z0-9]' | awk '{print $1}'i | sed "/:[0-9]/d")
    do
       tcpdump -l -i $interface -nn $@ | sed 's/^/[Interface:'"$interface"'] /' 2>/dev/null &
    done
fi
