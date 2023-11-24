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

build_wireless_firmware ${SENSOR_CONNECTED_HOME} ${SENSOR_CONNECTED_EXE_NAME}
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
  echo "iotlab-experiment submit -n ${COAP_SERVER_EXE_NAME} -d ${EXPERIMENT_TIME} -l grenoble,m3,${COAP_SERVER_NODE},${SENSE_FIRMWARE_HOME}/${COAP_SERVER_EXE_NAME}.elf"
  n_json=$(iotlab-experiment submit -n ${COAP_SERVER_EXE_NAME} -d ${EXPERIMENT_TIME} -l grenoble,m3,${COAP_SERVER_NODE},${SENSE_FIRMWARE_HOME}/${COAP_SERVER_EXE_NAME}.elf)
  n_node_job_id=$(echo $n_json | jq '.id')

  wait_for_job "${n_node_job_id}"

  create_tap_interface "${BORDER_ROUTER_NODE}" &

  iotlab-profile del -n group12
  iotlab-profile addm3 -n group12 -voltage -current -power -period 8244 -avg 4

  n_connected_sensor=$(iotlab-experiment submit -n ${SENSOR_CONNECTED_EXE_NAME} -d 20 -l grenoble,m3,${SENSOR_CONNECTED_NODE},${SENSE_FIRMWARE_HOME}/${SENSOR_CONNECTED_EXE_NAME}.elf,group12)
  n_connected_sensor_job_id=$(echo $n_json | jq '.id')
  create_stopper_script $n_node_job_id $border_router_job_id $n_connected_sensor_job_id

  echo "aiocoap-client coap://[2001:660:5307:3107:a4a9:dc28:5c45:38a9]/riot/board"
  echo "coap info"
  echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /.well-known/core"
  echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /riot/board"
  echo "coap get 192.168.2.135:5683 /.well-known/core"
  echo "coap get example.com:5683 /.well-known/core # with sock dns"
  echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /temperature"

  echo "nc m3-${SENSOR_CONNECTED_NODE} 20000"
  nc m3-${SENSOR_CONNECTED_NODE} 20000  

  
  stop_jobs "${n_connected_sensor_job_id}" "${n_node_job_id}" "${border_router_job_id}"
fi


