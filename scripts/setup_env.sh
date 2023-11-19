#!/usr/bin/env bash

export ARCH=iotlab-m3
export DEFAULT_CHANNEL=23
export ETHOS_BAUDRATE=500000
export TAP_INTERFACE=tap7

# https://www.iot-lab.info/legacy/tutorials/understand-ipv6-subnetting-on-the-fit-iot-lab-testbed/index.html
export BORDER_ROUTER_IP=2001:660:5307:3107::1/64

export BORDER_ROUTER_NODE=363 # border router
export COAP_SERVER_NODE=362
export GNRC_NETWORKING_NODE=361
export SENSOE_NODE=361

export BORDER_ROUTER_FOLDER_NAME=gnrc_border_router
export BORDER_ROTER_EXE_NAME=${BORDER_ROUTER_FOLDER_NAME}_gp12
export BORDER_ROUTER_HOME=${SENSE_HOME}/src/network/${BORDER_ROUTER_FOLDER_NAME}

export GNRC_NETWORKING_FOLDER_NAME=gnrc_networking
export GNRC_NETWORKING_EXE_NAME=${GNRC_NETWORKING_FOLDER_NAME}_gp12
export GNRC_NETWORKING_HOME=${SENSE_HOME}/src/network/${GNRC_NETWORKING_FOLDER_NAME}

#SENSE_SCRIPTS_HOME="${SENSE_HOME}/${SCRIPTS}"
#SENSE_STOPPERS_HOME="${SENSE_SCRIPTS_HOME}/stoppers"
#SENSE_FIRMWARE_HOME="${HOME}/bin"