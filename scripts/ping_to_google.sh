#!/usr/bin/env bash
#

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
fi

BORDER_ROUTER_NODE=28 # border router
GNRC_NETWORKING_NODE=26

echo "Build border router"
make ETHOS_BAUDRATE=500000 DEFAULT_CHANNEL=23 BOARD=${ARCH} -C ${BORDER_ROUTER_HOME}
echo "Build normal network node"
make ETHOS_BAUDRATE=500000 DEFAULT_CHANNEL=23 BOARD=${ARCH} -C ${GNRC_NETWORKING_HOME}

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  echo "Copy firmware files to shared"
  cp ${BORDER_ROUTER_HOME}/bin/${ARCH}/${BORDER_ROUTER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}
  cp ${GNRC_NETWORKING_HOME}/bin/${ARCH}/${GNRC_NETWORKING_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}

  # submit border router job and save job id
  echo "Submit job to node ${BORDER_ROUTER_NODE}"
  border_router_job_json=$(iotlab-experiment submit -n ${BORDER_ROUTER_EXE_NAME} -d 30 -l grenoble,m3,${BORDER_ROUTER_NODE},${SENSE_FIRMWARE_HOME}/${BORDER_ROUTER_EXE_NAME}.elf)
  border_router_job_id=$(echo $border_router_job_json | jq '.id')
  
  # wait for border router to start
  iotlab-experiment wait --timeout 30 --cancel-on-timeout -i $border_router_job_id --state Running

  # submit network router node job and save job id
  echo "Submit job to node ${GNRC_NETWORKING_NODE}"
  n_json=$(iotlab-experiment submit -n n2n-networking-node-gp12 -d 30 -l grenoble,m3,${GNRC_NETWORKING_NODE},${SENSE_FIRMWARE_HOME}/${GNRC_NETWORKING_EXE_NAME}.elf)
  n_node_job_id=$(echo $n_json | jq '.id')

  # create a file to stop the experiments
  echo "Creating '${SENSE_STOPPERS_HOME}/ping_to_google_stopper.sh' script"
  touch ${SENSE_STOPPERS_HOME}/ping_to_google_stopper.sh
  echo "iotlab-experiment stop -i $n_node_job_id" > ${SENSE_STOPPERS_HOME}/ping_to_google_stopper.sh
  echo "iotlab-experiment stop -i $border_router_job_id" >> ${SENSE_STOPPERS_HOME}/ping_to_google_stopper.sh

  # wait for network node to start
  iotlab-experiment wait --timeout 30 --cancel-on-timeout -i $n_node_job_id --state Running

  echo "Create tap interface 7"
  sudo ethos_uhcpd.py m3-${BORDER_ROUTER_NODE} ${TAP_INTERFACE} ${BORDER_ROUTER_IP} &

  # sleep sometime to allow interface to be created
  echo "I am sleeping for few seconds..."
  sleep 5

  # connecting to intermediate router
  # from this node you can type help
  # ifconfig
  # and also ping google
  # ping 2001:4860:4860::8888 or 2001:4860:4860::8844
  echo ""
  echo "You are connected to m3-26 node"
  echo "try to ping to google : ping 2001:4860:4860::8888"
  nc m3-${GNRC_NETWORKING_NODE} 20000

  # stop network node job (experiment)
  iotlab-experiment stop -i $n_node_job_id
  # stop border router node job (experiment)
  iotlab-experiment stop -i $border_router_job_id
fi

