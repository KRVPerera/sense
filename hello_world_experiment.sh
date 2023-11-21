#!/usr/bin/env bash

source ${SENSE_SCRIPTS_HOME}/setup_env.sh

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  source /opt/riot.source
fi


build_firmware ${SENSE_HOME}/tutorials_riotos/hello-world
echo tutorials_riotos/hello-world/bin/${ARCH}/hello-world.elf

NODE=361

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  cp tutorials_riotos/hello-world/bin/${ARCH}/hello-world.elf ${SENSE_FIRMWARE_HOME}

  n_json=$(iotlab-experiment submit -n hello_gp_12 -d 1 -l grenoble,m3,${NODE},${SENSE_FIRMWARE_HOME}/hello-world.elf)
  n_node_job_id=$(echo $n_json | jq '.id')

  create_stopper_script $n_node_job_id
  wait_for_job "${n_node_job_id}"

  echo "$ help"
  echo "$ restart"
  nc m3-${NODE} 20000

  stop_jobs "${n_node_job_id}"
fi
