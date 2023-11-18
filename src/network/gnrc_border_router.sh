#!/usr/bin/env bash
#

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
else
  echo "[ERROR] The environment variable IOT_LAB_FRONTEND_FQDN is not set."
fi

#ARCH=nrf52840dk # not available widely in the test bed
ARCH=iotlab-m3
NODE=362

# sensor nodes 20,21,22, 359, 361, 362

make BOARD=${ARCH} -C gnrc_border_router
echo gnrc_border_router/bin/${ARCH}/gnrc_border_router.elf

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp gnrc_border_router/bin/${ARCH}/gnrc_border_router.elf ~/shared/

  ## submitting a job in iot test bed with the firmware it self
  iotlab-experiment submit -n gnrc-border-router-gp12 -d 60 -l grenoble,m3,$NODE,~/shared/gnrc_border_router.elf
  iotlab-experiment wait --timeout 30 --cancel-on-timeout

  iotlab-experiment --jmespath="items[*].network_address | sort(@)" get --nodes
  sudo ethos_uhcpd.py m3-362 tap7 2001:660:5307:3108::1/64
  #iotlab-experiment stop
fi
