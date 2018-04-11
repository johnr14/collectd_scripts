#!/bin/bash

# This script uses hpasmcli to read ProLiant temperatures.

HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname -f)}"
INTERVAL="${COLLECTD_INTERVAL:-1}"

while sleep "$INTERVAL"; do

  IFS=$'\n'
  HPCONFIG=$(sudo -n /usr/sbin/ssacli "ctrl all show config")

  LOGICALDRV=$(echo "$HPCONFIG" | grep "logicaldrive" | awk '{ split($0, STR,","); print "LogicalDrive "$2" "STR[3]; }' | sed 's/)//g')
  PHYSICALDRV=$(echo "$HPCONFIG" | grep "physicaldrive" | awk '{ split($0, STR,","); print "PhysicalDrive "$2" " STR[4]; }' | sed 's/)//g')

 echo "$LOGICALDRV"
 echo "$PHYSICALDRV"

#  for line in $(sudo -n /sbin/ssascli "ctrl all show config"); do

 

 #   SENSOR=$(echo "$line" | awk '{ split($1, f1, "#"); printf("%02d",f1[2]); }')
  #  LOCATION=$(echo "$line" | awk '{ print $2; }' | sed -e 's/#//' -e 's/\///')
   # TEMP=$(echo "$line" | awk '{ split($3, f1, "/"); split(f1[1], f2, "C"); print f2[1]; }')

#    if [[ "$TEMP" != "-" ]]; then
 #     echo "PUTVAL ${HOSTNAME}/temperature-hpasmcli/temperature-${SENSOR}_${LOCATION} interval=$INTERVAL N:${TEMP}"
  #  fi

 # done

done
