#!/bin/bash

# This script uses hpasmcli to read ProLiant fans.

HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname -f)}"
INTERVAL="${COLLECTD_INTERVAL:-60}"

while sleep "$INTERVAL"; do

  IFS=$'\n'
  for line in $(sudo -n /sbin/hpasmcli -s "show fan" | grep -E '^#[0-9]+'); do

    FAN=$(echo "$line" | awk '{ split($1, f1, "#"); printf("%02d",f1[2]); }')
    LOCATION=$(echo "$line" | awk '{ print $2; }')
    SPEED=$(echo "$line" | awk '{ print $4; }')
    VALUE=$(echo "$line" | awk '{ split($5, f1, "%"); print f1[1]; }')

    if [[ "$SPEED" != "-" ]]; then
      echo "PUTVAL ${HOSTNAME}/fans-hpasmcli/percent-${FAN}_${LOCATION} interval=$INTERVAL N:${VALUE}"
    fi

  done

done
