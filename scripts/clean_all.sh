#!/usr/bin/env bash

source setup.sh
source ${SENSE_SCRIPTS_HOME}/setup_env.sh

make BOARD=${ARCH} -C ${BORDER_ROUTER_HOME} clean
make BOARD=${ARCH} -C ${GNRC_NETWORKING_HOME} clean
make BOARD=${ARCH} -C ${COAP_SERVER_HOME} clean
make BOARD=${ARCH} -C ${COAP_CLIENT_HOME} clean
make BOARD=${ARCH} -C ${SENSOR_READ_HOME} clean