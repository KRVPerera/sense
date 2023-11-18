#!/usr/bin/env bash
#

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
else
  echo "[ERROR] The environment variable IOT_LAB_FRONTEND_FQDN is not set."
fi

#ARCH=nrf52840dk # not available widely in the test bed
ARCH=iotlab-m3
NODE=361
# sensor nodes 20,21,22, 359, 361, 362

make BOARD=${ARCH} -C gnrc_networking
echo gnrc_networking/bin/${ARCH}/gnrc_networking.elf

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp gnrc_networking/bin/${ARCH}/gnrc_networking.elf ~/shared/

  ## submitting a job in iot test bed with the firmware it self
  iotlab-experiment submit -n gnrc_networking_gp12 -d 5 -l grenoble,m3,$NODE,~/shared/gnrc_networking.elf
  iotlab-experiment wait --timeout 30 --cancel-on-timeout

  iotlab-experiment --jmespath="items[*].network_address | sort(@)" get --nodes
fi
