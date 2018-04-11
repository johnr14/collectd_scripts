#!/bin/bash

# This script uses hpasmcli to read ProLiant temperatures.

HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname -f)}"
INTERVAL="${COLLECTD_INTERVAL:-60}"

while sleep "$INTERVAL"; do

  IFS=$'\n'
  for line in $(sudo -n /sbin/hpasmcli -s "show temp" | grep -E '^#[0-9]+'); do
 
    SENSOR=$(echo "$line" | awk '{ split($1, f1, "#"); printf("%02d",f1[2]); }')
    LOCATION=$(echo "$line" | awk '{ print $2; }' | sed -e 's/#//' -e 's/\///')
    TEMP=$(echo "$line" | awk '{ split($3, f1, "/"); split(f1[1], f2, "C"); print f2[1]; }')

    if [[ "$TEMP" != "-" ]]; then
      echo "PUTVAL ${HOSTNAME}/temperature-hpasmcli/temperature-${SENSOR}_${LOCATION} interval=$INTERVAL N:${TEMP}"
    fi

  done

done
