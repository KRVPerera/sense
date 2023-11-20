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
echo bin/${ARCH}/sensor-m3-temperature_gp12.elf

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp bin/${ARCH}/sensor-m3-temperature_gp12.elf ~/shared/

  iotlab-profile del -n group12
  iotlab-profile addm3 -n group12 -voltage -current -power -period 8244 -avg 64   ## choose avg from 1, 4, 16, 64, 128, 256, 512, 1024

  ## submitting a job in iot test bed with the firmware it self
  n_json=$(iotlab-experiment submit -n senor-temp-read-g12 -d 3 -l grenoble,m3,356,~/shared/sensor-m3-temperature_gp12.elf,group12)
  iotlab-experiment wait --timeout 30 --cancel-on-timeout

  n_node_job_id=$(echo $n_json | jq '.id')

  iotlab-experiment --jmespath="items[*].network_address | sort(@)" get --nodes
  make IOTLAB_NODE=auto term
  iotlab-experiment stop -i $n_node_job_id
fi
