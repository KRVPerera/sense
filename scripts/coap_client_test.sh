#!/usr/bin/env bash

source setup.sh
source ${SENSE_SCRIPTS_HOME}/setup_env.sh

build_wireless_firmware_forced ${COAP_CLIENT_TEST_HOME} ${COAP_CLIENT_TEST_EXE_NAME}
build_status=$?
if [ $build_status -ne 0 ]; then
    exit $build_status
fi

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  echo "cp ${COAP_CLIENT_TEST_HOME}/bin/${ARCH}/${COAP_CLIENT_TEST_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}"
  cp ${COAP_CLIENT_TEST_HOME}/bin/${ARCH}/${COAP_CLIENT_TEST_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}

  ## submitting a job in iot test bed with the firmware it self
  coap_client_job_json=$(iotlab-experiment submit -n ${COAP_CLIENT_TEST_EXE_NAME} -d ${EXPERIMENT_TIME} -l ${SENSE_SITE},m3,${COAP_CLIENT_TEST_NODE},${SENSE_FIRMWARE_HOME}/${COAP_CLIENT_TEST_EXE_NAME}.elf)
  coap_client_job_id=$(echo $coap_client_job_json | jq '.id')

  create_stopper_script $coap_client_job_id

  wait_for_job "${coap_client_job_id}"

  echo "aiocoap-client coap://[2001:660:5307:3107:a4a9:dc28:5c45:38a9]/riot/board"
  echo "coap info"
  echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /.well-known/core"
  echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /riot/board"
  echo "coap get 192.168.2.135:5683 /.well-known/core"
  echo "coap get example.com:5683 /.well-known/core # with sock dns"
  echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /temperature"

  echo "nc m3-${COAP_CLIENT_TEST_NODE} 20000"
  nc m3-${COAP_CLIENT_TEST_NODE} 20000

  stop_jobs $coap_client_job_id
fi
