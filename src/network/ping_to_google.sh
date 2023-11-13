#!/usr/bin/env bash
#

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
else
  echo "[ERROR] The environment variable IOT_LAB_FRONTEND_FQDN is not set."
fi

#ARCH=nrf52840dk # not available widely in the test bed
ARCH=iotlab-m3

# sensor nodes 20,21,22, 359, 361, 362

make BOARD=${ARCH} -C gnrc_border_router
make BOARD=${ARCH} -C gnrc_border_networking

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp gnrc_border_router/bin/${ARCH}/gnrc_border_router.elf ~/shared/
  cp gnrc_networking/bin/${ARCH}/gnrc_networking.elf ~/shared/

  ## submitting a job in iot test bed with the firmware it self
  iotlab-experiment submit -n n2n-border-router-gp12 -d 10 -l grenoble,m3,28,~/shared/gnrc_border_router.elf
  iotlab-experiment submit -n n2n-networking-node-gp12 -d 9 -l grenoble,m3,26,~/shared/gnrc_networking.elf
  iotlab-experiment wait --timeout 30 --cancel-on-timeout

  iotlab-experiment --jmespath="items[*].network_address | sort(@)" get --nodes
  sudo ethos_uhcpd.py m3-28 tap7 2001:660:3207:04c7::1/64
  #iotlab-experiment stop
fi
