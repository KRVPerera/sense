#!/usr/bin/env bash

source setup.sh
source ${SENSE_SCRIPTS_HOME}/setup_env.sh

if [ $ERROR_WRONG_SITE -ne 0]; then
	exit $ERROR_WRONG_SITE
fi

buILD_WIRELess_firmware_cached ${BORDER_ROUTER_HOME} ${BORDER_ROUTER_EXE_NAME}
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

    cp ${BORDER_ROUTER_HOME}/bin/${ARCH}/${BORDER_ROUTER_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}
    cp ${SENSOR_CONNECTED_HOME}/bin/${ARCH}/${SENSOR_CONNECTED_EXE_NAME}.elf ${SENSE_FIRMWARE_HOME}

    # submit border router job and save job id
    border_router_job_id=$(submit_border_router_job "${BORDER_ROUTER_NODE}")
    sensor_node_job_id=$(submit_sensor_node_job "${SENSOR_CONNECTED_NODE}")

    create_stopper_script $n_node_job_id $border_router_job_id $sensor_node_job_id

    wait_for_job "${border_router_job_id}"
    wait_for_job "${sensor_node_job_id}"

    create_tap_interface "${BORDER_ROUTER_NODE}" &

    echo "aiocoap-client coap://[2001:660:5307:3107:a4a9:dc28:5c45:38a9]/riot/board"
    echo "coap info"
    echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /.well-known/core"
    echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /riot/board"
    echo "coap get 192.168.2.135:5683 /.well-known/core"
    echo "coap get example.com:5683 /.well-known/core # with sock dns"
    echo "coap get [2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683 /temperature"

    echo "I am setting up the system......"
    sleep 10
    echo "Connecting to sensor node....."
    echo "nc m3-${SENSOR_CONNECTED_NODE} 20000"
    nc m3-${SENSOR_CONNECTED_NODE} 20000

    stop_jobs "${sensor_node_job_id}" "${n_node_job_id}" "${border_router_job_id}"
fi
