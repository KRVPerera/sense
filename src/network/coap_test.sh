#!/usr/bin/env bash
#

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
else
  echo "[ERROR] The environment variable IOT_LAB_FRONTEND_FQDN is not set."
fi

#ARCH=nrf52840dk # not available widely in the test bed
ARCH=iotlab-m3
NODE=359

# sensor nodes 20,21,22, 359, 361, 362

make BOARD=${ARCH} -C gcoap
echo gcoap/bin/${ARCH}/group_12_coap_client.elf

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp gcoap/bin/${ARCH}/group_12_coap_client.elf ~/shared/

  ## submitting a job in iot test bed with the firmware it self
  iotlab-experiment submit -n coap-client-gp12 -d 1 -l grenoble,m3,$NODE,~/shared/group_12_coap_client.elf
  iotlab-experiment wait --timeout 30 --cancel-on-timeout
  iotlab-experiment --jmespath="items[*].network_address | sort(@)" get --nodes
fi
