#!/usr/bin/env bash

source setup.sh
source ${SENSE_SCRIPTS_HOME}/setup_env.sh

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
fi

build_firmware ${SENSE_HOME}/tutorials_riotos/hello-world hello-world
build_status=$?
if [ $build_status -ne 0 ]; then
    exit $build_status
fi
echo tutorials_riotos/hello-world/bin/${ARCH}/hello-world.elf

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp tutorials_riotos/hello-world/bin/${ARCH}/hello-world.elf ${SENSE_FIRMWARE_HOME}

  n_json=$(iotlab-experiment submit -n hello_gp_12 -d 5 -l ${SENSE_SITE},m3,${HELLO_NODE},${SENSE_FIRMWARE_HOME}/hello-world.elf)
  n_node_job_id=$(echo $n_json | jq '.id')

  create_stopper_script $n_node_job_id
  wait_for_job "${n_node_job_id}"

  echo "$ nc m3-${HELLO_NODE} 20000"
  echo "$ help"
  echo "$ restart"
  nc m3-${HELLO_NODE} 20000

  stop_jobs "${n_node_job_id}"
fi
