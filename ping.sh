#!/bin/bash
#ping -c5 circa.ca | tail -n 1 | awk '{print $4}' | cut -d '/' -f 2
#Usage : ping.sh google.com 8.8.8.8

# This script uses hpasmcli to read ProLiant fans.

HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname -f)}"
INTERVAL="${COLLECTD_INTERVAL:-60}"

#IPS="$1"

while sleep "$INTERVAL"; do

   for IP in "$@"; do
        #AVERAGE=$(sudo -n /bin/ping -c1 $IP | tail -n 1 | awk '{print $4}' | cut -d '/' -f 2 | cut -d '.' -f 1)
	AVERAGE=$(sudo -n /bin/ping -c1 $IP | tail -n 1 | awk '{print $4}' | cut -d '/' -f 2)
	#AVERAGE=$(sudo -n /bin/ping -c1 google.ca)
        #echo "IP=$IP"
        if [ "$AVERAGE" ]; then
	   #HOST=$(echo "$IP" | sed s/[.]/-/g)
#	logger 'echo "PUTVAL ${HOSTNAME}/exec-ping/ping-google_ping interval=${INTERVAL} N:${AVERAGE}"'
           echo "PUTVAL ${HOSTNAME}/ping-average/gauge-${IP} interval=${INTERVAL} N:${AVERAGE}"
	   #echo "PUTVAL ${HOSTNAME}/exec-ping/ping-google_ping interval=${INTERVAL} N:${AVERAGE}"
        fi
   done
done



