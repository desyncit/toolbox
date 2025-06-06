#!/usr/bin/env bash

# Wrote this for a bug found in 
# firewalld with ipset lists 
# #2043289 && #2046343

MAIN="/usr/bin/firewall-cmd -q"
RELOAD="$MAIN --reload"
SET="geowhitelist"
SETCHK=`ipset -L $SET -terse`
DIPSETARGS="--perm --delete-ipset=$SET"

files+=('us_zone_le_2k.zone')
files+=('us_zone_le_4k.zone')
files+=('us_zone_le_6k.zone')
files+=('us_zone_le_8k.zone')
files+=('us_zone_le_10k.zone')
files+=('us_zone_le_12k.zone')
files+=('us_zone_le_14k.zone')
files+=('us_zone_le_16k.zone')
files+=('us_zone_le_18k.zone')
files+=('us_zone_le_20k.zone')
files+=('us_zone_le_24k.zone')
files+=('us_zone_le_25k.zone')
files+=('us_zone_le_28k.zone')
files+=('us_zone_le_30k.zone')
files+=('us_zone_le_32k.zone')

for c in ${files[@]}; do 
	awk 'END{printf("-> %s\tNR=%d\n",FILENAME,NR)}' ${c}
done


$SETCHK &> /dev/null

if [[ $? != 1 ]]; then
	/usr/bin/firewall-cmd -q  --perm --delete-ipset=$SET
	/usr/bin/firewall-cmd -q --reload
fi
	for i in "${files[@]}"; do
		start=`date +%s`
		printf "\n>> Start for %s\n+ =\033[%db\n" ${i} 75
			/usr/bin/firewall-cmd -q --perm --new-ipset=$SET --type=hash:net --option=family=inet --option=hashsize=4096 --option=maxelem=200000;
			/usr/bin/firewall-cmd -q --perm --ipset=$SET --add-entries-from-file=${i};
			/usr/bin/firewall-cmd -q --reload;
	        end=`date +%s`
		runtime=$( echo "$end - $start" | bc )
		printf '\n+ Runtime for %s: %dh:%dm:%ds\n+=\033[%db\n' ${i} $((runtime/3600)) $((runtime%3600/60)) $((runtime%60)) 75
			/usr/sbin/ipset -L $SET -terse
		printf "\n>> Deleting %s for test %s\n" $SET ${i}
                /usr/bin/firewall-cmd -q  --perm --delete-ipset=$SET
		/usr/bin/firewall-cmd -q --reload 
		unset start end runtime
	done
