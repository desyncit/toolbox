#!/bin/bash

#Variables
NEWUSERSFILE=/tmp/support/newusers

for ENTRY in $(cat /tmp/support/newusers)

	FIRSTNAME=$(echo $ENTRY | cut -d: -f1)
	LASTNAME=$(echo $ENTRY | cut -d: -f2)
	TIER=$(echo $ENTRY | cut -d: -f4)
	FIRTINITIAL=$(echo $FIRSTNAME | cut -c 1 | tr 'A-Z' 'a-z')
	LOWERLASTNAME=$(echo $LASTNAME | tr 'A-Z' 'a-z')

	ACCOUNTNAME=$FIRSTINITIAL$LOWERLASTNAME

	useradd $ACCOUNTNAME -c $FIRSTNAME $LASTNAME

done

TOTAL=$(cat $NEWUSERSFILE | wc -l)
TIER1COUNT=$(grep -c :1$ $NEWUSERSFILE)
TIER2COUNT=$(grep -c :2$ $NEWUSERSFILE)
TIER3COUNT=$(grep -c :3$ $NEWUSERSFILE)

TIER1PCT=$[ $TIER1COUNT * 100 / $TOTAL ]
TIER2PCT=$[ $TIER2COUNT * 100 / $TOTAL ]
TIER3PCT=$[ $TIER3COUNT * 100 / $TOTAL ]

echo "\"Tier 1\", \"$TIER1COUNT\",\"$TIER1PCT%\""
echo "\"Tier 2\", \"$TIER2COUNT\",\"$TIER2PCT%\""
echo "\"Tier 3\", \"$TIER3COUNT\",\"$TIER3PCT%\""
