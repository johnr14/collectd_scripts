#!/bin/bash

# This script uses ZFS zpool.
# Jonathan Rioux https://github.com/johnr14


#TODO IF RETURN A NULL, CHANGE IT TO 0 SO IT CAN CREATE INSERT IN DB !!


HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname -f)}"
INTERVAL="${COLLECTD_INTERVAL:-15}"

while sleep "$INTERVAL"; do

 #Keep it inside the loop so we can update new pools
 ZPOOL=$(/sbin/zpool list -p | tail -n +2)
 ZFSLIST=$(/sbin/zfs list -p | tail -n +2) #NOT USED, TO GET MORE PRECISE USAGE/FREE SPACE THAN ZPOOL

 #get a list of pools
 POOLS=$(echo "$ZPOOL" | awk '{ print $1}')
 POOLS=$(echo "$ZPOOL" | awk '{ print $1}')


  for POOL in $POOLS; do

    #Get values of the pools

    SIZE=$(echo "$ZPOOL" | grep "$POOL" | awk '{ print $2}')
    #SIZE=$(echo "$ZFSLIST" | grep "$POOL" | head -n1 | awk '{ print [}') #TO DO
    ALLOC=$(echo "$ZPOOL" | grep "$POOL" | awk '{ print $3}')
    FREE=$(echo "$ZPOOL" | grep "$POOL" | awk '{ print $4}')
    PERCENTFREE=$(echo "$ZPOOL" | grep "$POOL" | awk '{ print ($4/$2*100)}')
    PERCENTUSAGE=$(echo "$ZPOOL" | grep "$POOL" | awk '{ print ($3/$2*100)}')

    #HEALTH 0-1:GOOD or 2:BAD
    HEALTH=$(echo "$ZPOOL" | grep "$POOL" | awk '{ if ($9!="ONLINE") print "2"; else print "1"}')

    #echo "$POOL $SIZE $ALLOC $FREE $HEALTH"

    #Get scan status of pool
    STATUS=$(/sbin/zpool status $POOL)

    #Check if pool is beeing scrubed
    if [[ -n $(echo "$STATUS" | grep "scanned out") ]]; then
	#echo "POOL IS BEING SCRUB"
	#look for "scanned out"

	#grep scanned | awk '{ print $1" "$7}' | sed 's/,//g'
	#Convert values to bytes and  M/s
	#ScrubSpeed
	SCRUB_SPEED=$(echo "$STATUS" | grep scanned | awk '{ print $1" "$7}' | awk '{ print $2}' | sed -e 's/,//g' -e 's/\/s//g' | numfmt --from=iec)
	echo "PUTVAL ${HOSTNAME}/zpool-status/bytes-PoolScrubSpeed_${POOL} interval=$INTERVAL N:${SCRUB_SPEED}"
	#Scrubbed
	SCRUB_BYTES=$(echo "$STATUS" | grep scanned | awk '{ print $1}' | awk '{ system("numfmt --from=iec "$1) }')
	echo "PUTVAL ${HOSTNAME}/zpool-status/bytes-PoolScrubBytes_${POOL} interval=$INTERVAL N:${SCRUB_BYTES}"
	#Repaired
	SCRUB_REPAIRED=$(echo "$STATUS" | grep -e repaired -e "resilvered," | awk '{ print $1 }' | sed 's/,//g') # | numfmt --from=iec )
	if [[ $SCRUB_REPAIRED == "0B" || -n $SCRUB_REPAIRED ]]; then
                SCRUB_REPAIRED=0
        else
                SCRUB_REPAIRED=$(echo "$SCRUB_REPAIRED" | numfmt --from=iec )
        fi
	echo "PUTVAL ${HOSTNAME}/zpool-status/bytes-PoolScrubRepaired_${POOL} interval=$INTERVAL N:${SCRUB_REPAIRED}"
	#ScrubDone in %
	SCRUB_DONE=$(echo "$STATUS" | grep -e repaired -e "resilvered," | awk '{ print $3}' | sed -e 's/%//g')
	echo "PUTVAL ${HOSTNAME}/zpool-status/percent-PoolScrubDone_${POOL} interval=$INTERVAL N:${SCRUB_DONE}"
	#ScrubTimeRemaining
	SCRUB_TIME_REMAINING=$(echo "$STATUS" | grep scanned | awk '{ print $8}' | sed 's/h/ /g;s/m//g' | awk '{print ($1*60+$2)}')
	echo "PUTVAL ${HOSTNAME}/zpool-status/gauge-PoolScrubTimeRemaining_${POOL} interval=$INTERVAL N:${SCRUB_TIME_REMAINING}"

    fi

    #Check scrub status
    if [[ -n $(echo "$STATUS" | grep "scrub repaired") ]]; then
	#echo "Pool was scrubed and it is finished"
       	#look for "scrub repaired"
	#grep "scrub repaired" | awk '{ print $4" "$6" "$8}'

	#ScrubRepair
	#BUG
	#numfmt: invalid suffix in input: ‘0B’

	SCRUB_REPAIRED=$(echo "$STATUS" | grep "scrub repaired" | awk '{ print $4 }') # | numfmt --from=iec $1)
	if [[ $SCRUB_REPAIRED == "0B" || -n $SCRUB_REPAIRED ]]; then
		SCRUB_REPAIRED=0
	else
		SCRUB_REPAIRED=$(echo "$SCRUB_REPAIRED" | numfmt --from=iec )
	fi
	echo "PUTVAL ${HOSTNAME}/zpool-status/bytes-PoolScrubRepaired_${POOL} interval=$INTERVAL N:${SCRUB_REPAIRED}"
	#ScrubTime
	SCRUB_TIME=$(echo "$STATUS" | grep "scrub repaired" | awk '{ print $6}' | sed 's/h/ /g;s/m//g' | awk '{print ($1*60+$2)}')
	echo "PUTVAL ${HOSTNAME}/zpool-status/gauge-PoolScrubTime_${POOL} interval=$INTERVAL N:${SCRUB_TIME}"
	#ScrubErrors
	SCRUB_ERRORS=$(echo "$STATUS" | grep "scrub repaired" | awk '{ print $8}')
	echo "PUTVAL ${HOSTNAME}/zpool-status/gauge-PoolScrubErrors_${POOL} interval=$INTERVAL N:${SCRUB_ERRORS}"
    fi

    #else pool scrub was cancelled


    #Poolsize
    echo "PUTVAL ${HOSTNAME}/zpool-status/bytes-PoolSize_${POOL} interval=$INTERVAL N:${SIZE}"
    #PoolAlloc
    echo "PUTVAL ${HOSTNAME}/zpool-status/bytes-PoolAlloc_${POOL} interval=$INTERVAL N:${ALLOC}"
    #PoolFree
    echo "PUTVAL ${HOSTNAME}/zpool-status/bytes-PoolFree_${POOL} interval=$INTERVAL N:${FREE}"
    #PoolUsage
    echo "PUTVAL ${HOSTNAME}/zpool-status/percent-PoolUsage_${POOL} interval=$INTERVAL N:${PERCENTUSAGE}"
    #PoolUnused NOTE: IT USES ZPOOL TOTAL POOL SIZE, SO IN RAIDZ-1-2-3 IT DOESN'T EQUAL TOTAL REAL SPACE FOR WRITING
    echo "PUTVAL ${HOSTNAME}/zpool-status/percent-PoolUnused_${POOL} interval=$INTERVAL N:${PERCENTFREE}"
    #PoolHealth
    echo "PUTVAL ${HOSTNAME}/zpool-status/gauge-PoolHealth_${POOL} interval=$INTERVAL N:${HEALTH}"


  done


done
