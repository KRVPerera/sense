#!/usr/bin/env bash

source ${SENSE_SCRIPTS_HOME}/common_functions.sh

export BORDER_ROUTER_NODE=329 # border router
export COAP_SERVER_NODE=328
export GNRC_NETWORKING_NODE=326
export COAP_CLIENT_NODE=327
export SENSOR_NODE=324
export SENSOR_CONNECTED_NODE=320
export COAP_CLIENT_TEST_NODE=325

# comment this out in production
export COAP_SERVER_IP="[2001:660:5307:3107:a4a9:dc28:5c45:38a9]:5683"
export COAP_SERVER_IP_ONLY=$(extract_ip "$COAP_SERVER_IP")


# https://www.iot-lab.info/legacy/tutorials/understand-ipv6-subnetting-on-the-fit-iot-lab-testbed/index.html
export BORDER_ROUTER_IP=2001:660:5307:3107::1/64
# export BORDER_ROUTER_IP=2001:660:5307:3108::1/64
# export BORDER_ROUTER_IP=2001:660:5307:3109::1/64
# export BORDER_ROUTER_IP=2001:660:5307:3110::1/64

export ARCH=iotlab-m3

# values are from 11-26
export DEFAULT_CHANNEL=23
# export DEFAULT_CHANNEL=13

export ETHOS_BAUDRATE=500000
export TAP_INTERFACE=tap7
# export TAP_INTERFACE=tap4
# export TAP_INTERFACE=tap5
# export TAP_INTERFACE=tap6

# this is seconds
export JOB_WAIT_TIMEOUT=60
export EXPERIMENT_TIME=120

export BORDER_ROUTER_FOLDER_NAME=gnrc_border_router
export BORDER_ROUTER_EXE_NAME=${BORDER_ROUTER_FOLDER_NAME}_gp12
export BORDER_ROUTER_HOME=${SENSE_HOME}/src/network/${BORDER_ROUTER_FOLDER_NAME}

export GNRC_NETWORKING_FOLDER_NAME=gnrc_networking
export GNRC_NETWORKING_EXE_NAME=${GNRC_NETWORKING_FOLDER_NAME}_gp12
export GNRC_NETWORKING_HOME=${SENSE_HOME}/src/network/${GNRC_NETWORKING_FOLDER_NAME}

export COAP_SERVER_FOLDER_NAME=nanocoap_server
export COAP_SERVER_EXE_NAME=${COAP_SERVER_FOLDER_NAME}_gp12
export COAP_SERVER_HOME=${SENSE_HOME}/src/network/${COAP_SERVER_FOLDER_NAME}

export COAP_CLIENT_FOLDER_NAME=gcoap
export COAP_CLIENT_EXE_NAME=${COAP_CLIENT_FOLDER_NAME}_gp12
export COAP_CLIENT_HOME=${SENSE_HOME}/src/network/${COAP_CLIENT_FOLDER_NAME}

export COAP_CLIENT_TEST_FOLDER_NAME=gcoap_test
export COAP_CLIENT_TEST_EXE_NAME=${COAP_CLIENT_TEST_FOLDER_NAME}_gp12
export COAP_CLIENT_TEST_HOME=${SENSE_HOME}/src/network/${COAP_CLIENT_TEST_FOLDER_NAME}

export SENSOR_READ_FOLDER_NAME=sensor-m3-temperature
export SENSOR_READ_EXE_NAME=${SENSOR_READ_FOLDER_NAME}_gp12
export SENSOR_READ_HOME=${SENSE_HOME}/src/sensor/${SENSOR_READ_FOLDER_NAME}

export SENSOR_CONNECTED_FOLDER_NAME=sensor-connected
export SENSOR_CONNECTED_EXE_NAME=${SENSOR_CONNECTED_FOLDER_NAME}_gp12
export SENSOR_CONNECTED_HOME=${SENSE_HOME}/src/sensor/${SENSOR_CONNECTED_FOLDER_NAME}

#SENSE_SCRIPTS_HOME="${SENSE_HOME}/${SCRIPTS}"
#SENSE_STOPPERS_HOME="${SENSE_SCRIPTS_HOME}/stoppers"
#SENSE_FIRMWARE_HOME="${HOME}/bin"

