#!/usr/bin/env bash

source setup.sh
source ${SENSE_SCRIPTS_HOME}/setup_env.sh

build_wireless_firmware_cached ${BORDER_ROUTER_HOME} ${BORDER_ROUTER_EXE_NAME}
build_status=$?
if [ $build_status -ne 0 ]; then
    exit $build_status
fi

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp ${BORDER_ROUTER_HOME}/bin/${ARCH}/${BORDER_ROUTER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}

  ## submitting a job in iot test bed with the firmware it self
  border_router_job_id=$(submit_border_router_job "${BORDER_ROUTER_NODE}")

  create_stopper_script $border_router_job_id

  wait_for_job "${border_router_job_id}"

  iotlab-experiment --jmespath="items[*].network_address | sort(@)" get --nodes

  BORDER_ROUTER_IP=2001:660:5307:3108::1/64

  create_tap_interface "${BORDER_ROUTER_NODE}"

  stop_jobs $border_router_job_id
fi
