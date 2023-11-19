#!/usr/bin/env bash

source ${SENSE_SCRIPTS_HOME}/setup_env.sh

make BOARD=${ARCH} -C ${COAP_CLIENT_HOME}

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
  echo "cp ${COAP_CLIENT_HOME}/bin/${ARCH}/${COAP_CLIENT_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}"
  cp ${COAP_CLIENT_HOME}/bin/${ARCH}/${COAP_CLIENT_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}

  ## submitting a job in iot test bed with the firmware it self
  coap_client_job_json=$(iotlab-experiment submit -n ${COAP_CLIENT_EXE_NAME} -d ${EXPERIMENT_TIME} -l grenoble,m3,${COAP_CLIENT_NODE},${SENSE_FIRMWARE_HOME}/${COAP_CLIENT_EXE_NAME}.elf)
  coap_client_job_id=$(echo $coap_client_job_json | jq '.id')


  echo "Creating '${SENSE_STOPPERS_HOME}/coap_client_stopper.sh' script"
  touch ${SENSE_STOPPERS_HOME}/coap_client_stopper.sh
  echo "iotlab-experiment stop -i $coap_client_job_id" > ${SENSE_STOPPERS_HOME}/coap_client_stopper.sh

  
  iotlab-experiment wait --timeout ${JOB_WAIT_TIMEOUT} --cancel-on-timeout -i $coap_client_job_id --state Running
  iotlab-experiment --jmespath="items[*].network_address | sort(@)" get --nodes

  echo "aiocoap-client coap://[2001:660:3207:4c1:1711:6b10:65fd:bd36]/riot/board"
  echo "coap info"
  echo "coap get [2001:660:5307:3107:a436:ee73:926e:840c]:5683 /.well-known/core"
  echo "coap get 192.168.2.135:5683 /.well-known/core"
  echo "coap get example.com:5683 /.well-known/core # with sock dns"

  nc m3-${COAP_CLIENT_NODE} 20000

  iotlab-experiment stop -i $coap_client_job_id
fi
