#!/usr/bin/env bash

source setup.sh
source ${SENSE_SCRIPTS_HOME}/setup_env.sh

build_wireless_firmware ${SENSOR_CONNECTED_HOME} ${SENSOR_CONNECTED_EXE_NAME}
build_status=$?
if [ $build_status -ne 0 ]; then
    exit $build_status
fi

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp ${SENSOR_CONNECTED_HOME}/bin/${ARCH}/${SENSOR_CONNECTED_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}

  iotlab-profile del -n group12
  iotlab-profile addm3 -n group12 -voltage -current -power -period 8244 -avg 4

  n_json=$(iotlab-experiment submit -n ${SENSOR_CONNECTED_EXE_NAME} -d 20 -l ${SENSE_SITE},m3,${SENSOR_CONNECTED_NODE},${SENSE_FIRMWARE_HOME}/${SENSOR_CONNECTED_EXE_NAME}.elf,group12)
  n_node_job_id=$(echo $n_json | jq '.id')

  create_stopper_script $n_node_job_id

  wait_for_job "${n_node_job_id}"

  echo "aiocoap-client coap://[2001:660:5307:3107:a4a9:dc28:5c45:38a9]/riot/board"
  echo "coap info"
  echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /.well-known/core"
  echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /riot/board"
  echo "coap get 192.168.2.135:5683 /.well-known/core"
  echo "coap get example.com:5683 /.well-known/core # with sock dns"
  echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /temperature"

  echo "nc m3-${SENSOR_CONNECTED_NODE} 20000"
  nc m3-${SENSOR_CONNECTED_NODE} 20000

  stop_jobs "${n_node_job_id}"
fi
