#!/usr/bin/env bash

source setup.sh
source ${SENSE_SCRIPTS_HOME}/setup_env.sh

build_wireless_firmware_cached ${BORDER_ROUTER_HOME} ${BORDER_ROUTER_EXE_NAME}
build_status=$?
if [ $build_status -ne 0 ]; then
    exit $build_status
fi
build_wireless_firmware ${COAP_SERVER_HOME} ${COAP_SERVER_EXE_NAME}
build_status=$?
if [ $build_status -ne 0 ]; then
    exit $build_status
fi

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  echo "Copy firmware files to shared"
  echo "cp ${BORDER_ROUTER_HOME}/bin/${ARCH}/${BORDER_ROUTER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}"
  echo "cp ${COAP_SERVER_HOME}/bin/${ARCH}/${COAP_SERVER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}"
  
  cp ${BORDER_ROUTER_HOME}/bin/${ARCH}/${BORDER_ROUTER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}
  cp ${COAP_SERVER_HOME}/bin/${ARCH}/${COAP_SERVER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}
  # submit border router job and save job id
  border_router_job_id=$(submit_border_router_job "${BORDER_ROUTER_NODE}")

  wait_for_job "${border_router_job_id}"

  # submit network router node job and save job id
  echo "Submit job to node ${COAP_SERVER_NODE}"
  echo "iotlab-experiment submit -n ${COAP_SERVER_EXE_NAME} -d ${EXPERIMENT_TIME} -l ${SENSE_SITE},m3,${COAP_SERVER_NODE},${SENSE_FIRMWARE_HOME}/${COAP_SERVER_EXE_NAME}.elf"
  n_json=$(iotlab-experiment submit -n ${COAP_SERVER_EXE_NAME} -d ${EXPERIMENT_TIME} -l ${SENSE_SITE},m3,${COAP_SERVER_NODE},${SENSE_FIRMWARE_HOME}/${COAP_SERVER_EXE_NAME}.elf)
  n_node_job_id=$(echo $n_json | jq '.id')

  create_stopper_script $n_node_job_id $border_router_job_id

  wait_for_job "${n_node_job_id}"

  create_tap_interface "${BORDER_ROUTER_NODE}"

  stop_jobs "${n_node_job_id}" "${border_router_job_id}"
fi


