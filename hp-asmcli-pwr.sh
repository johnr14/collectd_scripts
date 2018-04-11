#!/bin/bash

# This script uses hpasmcli to read ProLiant temperatures.
# Based on work from Mark Nellemann https://mark.nellemann.nu/2015/02/12/hp-proliant-fan-temperature-monitoring/
# Jonathan Rioux https://github.com/johnr14

HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname -f)}"
INTERVAL="${COLLECTD_INTERVAL:-1}"

while sleep "$INTERVAL"; do

  TOTPWR=0
  PWRSUPP=1

  for line in $(sudo -n /sbin/hpasmcli -s  "show powersupply" | grep Watts | awk '{print $3}'); do
    PWR=$line

    if [[ "$PWR" != "-" ]]; then
      echo "PUTVAL ${HOSTNAME}/powersupply-hpasmcli/power-PowerSupply${PWRSUPP} interval=$INTERVAL N:${PWR}"
    fi

   PWRSUPP=$((${PWRSUPP}+1))
   TOTPWR=$((${TOTPWR}+${PWR}))

  done

 
  if [[ "$PWR" != "-" ]]; then
      #Send total power usage
      echo "PUTVAL ${HOSTNAME}/powersupply-hpasmcli/power-PowerSupplyTotal interval=$INTERVAL N:${TOTPWR}"
  fi


done
