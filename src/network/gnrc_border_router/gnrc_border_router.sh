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

make BOARD=${ARCH}
echo bin/${ARCH}/gnrc_border_router.elf

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp bin/${ARCH}/gnrc_border_router.elf ~/shared/

#  iotlab-profile del -n group12
#  iotlab-profile addm3 -n group12 -voltage -current -power -period 8244 -avg 4

  ## submitting a job in iot test bed with the firmware it self
  iotlab-experiment submit -n senor-temp-read-g12 -d 3 -l grenoble,m3,362,~/shared/gnrc_border_router.elf
  iotlab-experiment wait --timeout 30 --cancel-on-timeout

  iotlab-experiment --jmespath="items[*].network_address | sort(@)" get --nodes
  sudo ethos_uhcpd.py m3-362 tap7 2001:660:3207:04c7::1/64
  #iotlab-experiment stop
fi
