#!/usr/bin/env bash

source ${SENSE_SCRIPTS_HOME}/setup_env.sh

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
fi

echo "Build border router"
echo "make ETHOS_BAUDRATE=${ETHOS_BAUDRATE} DEFAULT_CHANNEL=${DEFAULT_CHANNEL} BOARD=${ARCH} -C ${BORDER_ROUTER_HOME}"
make ETHOS_BAUDRATE=${ETHOS_BAUDRATE} DEFAULT_CHANNEL=${DEFAULT_CHANNEL} BOARD=${ARCH} -C ${BORDER_ROUTER_HOME}
echo "Build normal network node"
echo "make ETHOS_BAUDRATE=${ETHOS_BAUDRATE} DEFAULT_CHANNEL=${DEFAULT_CHANNEL} BOARD=${ARCH} -C ${COAP_SERVER_HOME}"
make ETHOS_BAUDRATE=${ETHOS_BAUDRATE} DEFAULT_CHANNEL=${DEFAULT_CHANNEL} BOARD=${ARCH} -C ${COAP_SERVER_HOME}

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  echo "Copy firmware files to shared"
  echo "cp ${BORDER_ROUTER_HOME}/bin/${ARCH}/${BORDER_ROUTER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}"
  echo "cp ${COAP_SERVER_HOME}/bin/${ARCH}/${COAP_SERVER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}"
  
  cp ${BORDER_ROUTER_HOME}/bin/${ARCH}/${BORDER_ROUTER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}
  cp ${COAP_SERVER_HOME}/bin/${ARCH}/${COAP_SERVER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}

  # submit border router job and save job id
  echo "Submit job to node ${BORDER_ROUTER_NODE}"
  echo "iotlab-experiment submit -n ${BORDER_ROUTER_EXE_NAME} -d ${EXPERIMENT_TIME} -l grenoble,m3,${BORDER_ROUTER_NODE},${SENSE_FIRMWARE_HOME}/${BORDER_ROUTER_EXE_NAME}.elf"
  border_router_job_json=$(iotlab-experiment submit -n ${BORDER_ROUTER_EXE_NAME} -d ${EXPERIMENT_TIME} -l grenoble,m3,${BORDER_ROUTER_NODE},${SENSE_FIRMWARE_HOME}/${BORDER_ROUTER_EXE_NAME}.elf)
  border_router_job_id=$(echo $border_router_job_json | jq '.id')

  # wait for border router to start
  iotlab-experiment wait --timeout ${JOB_WAIT_TIMEOUT} --cancel-on-timeout -i $border_router_job_id --state Running

  # submit network router node job and save job id
  echo "Submit job to node ${COAP_SERVER_NODE}"
  echo "iotlab-experiment submit -n ${COAP_SERVER_EXE_NAME} -d ${EXPERIMENT_TIME} -l grenoble,m3,${COAP_SERVER_NODE},${SENSE_FIRMWARE_HOME}/${COAP_SERVER_EXE_NAME}.elf"
  n_json=$(iotlab-experiment submit -n ${COAP_SERVER_EXE_NAME} -d ${EXPERIMENT_TIME} -l grenoble,m3,${COAP_SERVER_NODE},${SENSE_FIRMWARE_HOME}/${COAP_SERVER_EXE_NAME}.elf)
  n_node_job_id=$(echo $n_json | jq '.id')

  # create a file to stop the experiments
  echo "Creating '${SENSE_STOPPERS_HOME}/coap_server.sh' script"
  touch ${SENSE_STOPPERS_HOME}/coap_server.sh
  echo "iotlab-experiment stop -i $n_node_job_id" > ${SENSE_STOPPERS_HOME}/coap_server.sh
  echo "iotlab-experiment stop -i $border_router_job_id" >> ${SENSE_STOPPERS_HOME}/coap_server.sh

  # wait for network node to start
  echo "iotlab-experiment wait --timeout ${JOB_WAIT_TIMEOUT} --cancel-on-timeout -i $n_node_job_id --state Running"
  iotlab-experiment wait --timeout ${JOB_WAIT_TIMEOUT} --cancel-on-timeout -i $n_node_job_id --state Running

  echo "Create tap interface ${TAP_INTERFACE}"
  sudo ethos_uhcpd.py m3-${BORDER_ROUTER_NODE} ${TAP_INTERFACE} ${BORDER_ROUTER_IP} &

  # sleep sometime to allow interface to be created
  echo "I am sleeping for few seconds..."
  sleep 5

  echo "nib neigh"
  nc m3-${BORDER_ROUTER_NODE} 20000
fi


