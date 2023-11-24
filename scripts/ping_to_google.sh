#!/usr/bin/env bash

source setup.sh
source ${SENSE_SCRIPTS_HOME}/setup_env.sh

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
fi

BORDER_ROUTER_NODE=28 # border router
GNRC_NETWORKING_NODE=26

build_wireless_firmware_cached ${BORDER_ROUTER_HOME} ${BORDER_ROUTER_EXE_NAME}
build_status=$?
if [ $build_status -ne 0 ]; then
    exit $build_status
fi

build_wireless_firmware_cached ${GNRC_NETWORKING_HOME} ${GNRC_NETWORKING_EXE_NAME}
build_status=$?
if [ $build_status -ne 0 ]; then
    exit $build_status
fi

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  echo "Copy firmware files to shared"
  echo "cp ${BORDER_ROUTER_HOME}/bin/${ARCH}/${BORDER_ROUTER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}"
  echo "cp ${GNRC_NETWORKING_HOME}/bin/${ARCH}/${GNRC_NETWORKING_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}"
  
  cp ${BORDER_ROUTER_HOME}/bin/${ARCH}/${BORDER_ROUTER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}
  cp ${GNRC_NETWORKING_HOME}/bin/${ARCH}/${GNRC_NETWORKING_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}

  border_router_job_id=$(submit_border_router_job "${BORDER_ROUTER_NODE}")
  wait_for_job "${border_router_job_id}"

  # submit network router node job and save job id
  echo "Submit job to node ${GNRC_NETWORKING_NODE}"
  n_json=$(iotlab-experiment submit -n ${GNRC_NETWORKING_EXE_NAME} -d ${EXPERIMENT_TIME} -l ${SENSE_SITE},m3,${GNRC_NETWORKING_NODE},${SENSE_FIRMWARE_HOME}/${GNRC_NETWORKING_EXE_NAME}.elf)
  n_node_job_id=$(echo $n_json | jq '.id')

  # create a file to stop the experiments
  create_stopper_script $n_node_job_id $border_router_job_id

  wait_for_job "${n_node_job_id}"

  create_tap_interface "${BORDER_ROUTER_NODE}" &

  echo "I am sleeping for few seconds..."
  sleep 5

  # connecting to intermediate router
  # from this node you can type help
  # ifconfig
  # and also ping google
  # ping 2001:4860:4860::8888 or 2001:4860:4860::8844
  echo ""
  echo "You are connected to m3-${GNRC_NETWORKING_NODE} node"
  echo "try to ping to google : ping 2001:4860:4860::8888"
  nc m3-${GNRC_NETWORKING_NODE} 20000

  stop_jobs "${n_node_job_id}" "${border_router_job_id}"
fi


