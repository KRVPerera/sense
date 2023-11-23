#!/usr/bin/env bash

source ${SENSE_SCRIPTS_HOME}/setup_env.sh

build_wireless_firmware ${SENSOR_READ_HOME} ${SENSOR_READ_EXE_NAME}
build_status=$?
if [ $build_status -ne 0 ]; then
    exit $build_status
fi

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp ${SENSOR_READ_HOME}/bin/${ARCH}/${SENSOR_READ_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}

  iotlab-profile del -n group12
  iotlab-profile addm3 -n group12 -voltage -current -power -period 8244 -avg 4

  n_json=$(iotlab-experiment submit -n ${SENSOR_READ_EXE_NAME} -d 20 -l grenoble,m3,${SENSOR_NODE},${SENSE_FIRMWARE_HOME}/${SENSOR_READ_EXE_NAME}.elf,group12)
  n_node_job_id=$(echo $n_json | jq '.id')

  create_stopper_script $n_node_job_id

  wait_for_job "${n_node_job_id}"

  echo "nc m3-${SENSOR_NODE} 20000"
  nc m3-${SENSOR_NODE} 20000

  stop_jobs "${n_node_job_id}"
fi
