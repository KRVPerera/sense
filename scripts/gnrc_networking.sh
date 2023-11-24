#!/usr/bin/env bash

source setup.sh
source ${SENSE_SCRIPTS_HOME}/setup_env.sh

build_wireless_firmware_cached ${GNRC_NETWORKING_HOME} ${GNRC_NETWORKING_EXE_NAME}
build_status=$?
if [ $build_status -ne 0 ]; then
    exit $build_status
fi

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp ${GNRC_NETWORKING_HOME}/bin/${ARCH}/${GNRC_NETWORKING_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}

  n_json=$(iotlab-experiment submit -n ${GNRC_NETWORKING_EXE_NAME} -d ${EXPERIMENT_TIME} -l ${SENSE_SITE},m3,${GNRC_NETWORKING_NODE},${SENSE_FIRMWARE_HOME}/${GNRC_NETWORKING_EXE_NAME}.elf)
  n_node_job_id=$(echo $n_json | jq '.id')

  create_stopper_script $n_node_job_id

  wait_for_job "${n_node_job_id}"

  nc m3-${GNRC_NETWORKING_NODE} 20000

  stop_jobs "${n_node_job_id}"
fi
