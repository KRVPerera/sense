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
  border_router_job_json=$(iotlab-experiment submit -n n2n-border-router-gp12 -d 30 -l grenoble,m3,28,~/shared/gnrc_border_router.elf)
  border_router_job_id=$(echo $border_router_job_json | jq '.id')
  iotlab-experiment wait --timeout 30 --cancel-on-timeout -i $border_router_job_id --state Running
  n_json=$(iotlab-experiment submit -n n2n-networking-node-gp12 -d 30 -l grenoble,m3,26,~/shared/gnrc_networking.elf)
  n_node_job_id=$(echo $n_json | jq '.id')
  iotlab-experiment wait --timeout 30 --cancel-on-timeout -i $n_node_job_id --state Running
  sudo ethos_uhcpd.py m3-28 tap7 2001:660:3207:04c7::1/64
  #iotlab-experiment stop

  # connecting to intermediate router
  # from this node you can type help
  # ifconfig
  # and also ping google
  # ping 2001:4860:4860::8888 or 2001:4860:4860::8844
  nc m3-26 20000
fi
