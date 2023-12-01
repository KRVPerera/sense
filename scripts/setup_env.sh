#!/usr/bin/env bash

source ${SENSE_SCRIPTS_HOME}/common_functions.sh
# grenoble, paris, lille, saclay, strasbourg
export SENSE_SITE=paris

printf "%-25s %s\n" "SENSE_SITE:" "$SENSE_SITE"

# Get the current hostname
current_hostname=$(hostname)

# Compare the current hostname with the expected one
if [ "$current_hostname" != "$SENSE_SITE" ]; then
	error_message="ERROR: You are running this script on site '$current_hostname', not on '$SENSE_SITE'."
	# Displaying the Error Message in a Box
	echo "***********************************************************************"
	echo "*                                                                     *"
	printf "* %-36s*\n" "$error_message"
	printf "* %-68s*\n" $0 
	printf "* %s %-56s*\n" "SENSE_SITE:" "$SENSE_SITE"
	echo "* Change SENSE_SITE variable in setup_env.sh                          *"
	echo "*                                                                     *"
	echo "***********************************************************************"
	export ERROR_WRONG_SITE=1
	exit $ERROR_WRONG_SITE
fi


export BORDER_ROUTER_NODE=60 # Border router

# Incrementally set other variables based on BORDER_ROUTER_NODE
export COAP_SERVER_NODE=$((BORDER_ROUTER_NODE + 1))
export SENSOR_CONNECTED_NODE=$((BORDER_ROUTER_NODE + 2))
export GNRC_NETWORKING_NODE=$((BORDER_ROUTER_NODE + 3))
export COAP_CLIENT_NODE=$((BORDER_ROUTER_NODE + 4))
export SENSOR_NODE=$((BORDER_ROUTER_NODE + 5))
export COAP_CLIENT_TEST_NODE=$((BORDER_ROUTER_NODE + 6))
export HELLO_NODE=$((BORDER_ROUTER_NODE + 7))

printf "%-25s %s\n" "BORDER_ROUTER_NODE:" "$BORDER_ROUTER_NODE"
printf "%-25s %s\n" "COAP_SERVER_NODE:" "$COAP_SERVER_NODE"
printf "%-25s %s\n" "SENSOR_CONNECTED_NODE:" "$SENSOR_CONNECTED_NODE"
printf "%-25s %s\n" "GNRC_NETWORKING_NODE:" "$GNRC_NETWORKING_NODE"
printf "%-25s %s\n" "COAP_CLIENT_NODE:" "$COAP_CLIENT_NODE"
printf "%-25s %s\n" "SENSOR_NODE:" "$SENSOR_NODE"
printf "%-25s %s\n" "COAP_CLIENT_TEST_NODE:" "$COAP_CLIENT_TEST_NODE"
printf "%-25s %s\n" "HELLO_NODE:" "$HELLO_NODE"
printf "%-25s %s\n" "SITE:" "$SENSE_SITE"

# comment this out in production
if [ -z "$COAP_SERVER_IP" ]; then
    # If not set, then export it with the specified value
    export COAP_SERVER_IP="[2001:660:4403:497:a417:1216:7ea7:9acb]:5683"
fi
export COAP_SERVER_IP_ONLY=$(extract_ip "$COAP_SERVER_IP")

# Site		    subnets	from			        to
# Grenoble	    128	    2001:660:5307:3100::/64	2001:660:5307:317f::/64
# Lille		    128	    2001:660:4403:0480::/64	2001:660:4403:04ff::/64
# Paris		    128	    2001:660:330f:a280::/64	2001:660:330f:a2ff::/64
# Saclay	    64	    2001:660:3207:04c0::/64	2001:660:3207:04ff::/64
# Strasbourg	32	    2001:660:4701:f0a0::/64	2001:660:4701:f0bf::/64

# https://www.iot-lab.info/legacy/tutorials/understand-ipv6-subnetting-on-the-fit-iot-lab-testbed/index.html

if [ "$SENSE_SITE" = "grenoble" ]; then
    # 2001:660:5307:3100::/64	2001:660:5307:317f::/64
    export BORDER_ROUTER_IP=2001:660:5307:3108::1/64
elif [ "$SENSE_SITE" = "paris" ]; then
    # 2001:660:330f:a280::/64   2001:660:330f:a2ff::/64
    export BORDER_ROUTER_IP=2001:660:330f:a293::1/64
elif [ "$SENSE_SITE" = "lille" ]; then
    # 2001:660:4403:0480::/64	2001:660:4403:04ff::/64
    export BORDER_ROUTER_IP=2001:660:4403:0493::1/64
elif [ "$SENSE_SITE" = "saclay" ]; then
    # 2001:660:3207:04c0::/64	2001:660:3207:04ff::/64
    export BORDER_ROUTER_IP=2001:660:3207:04de::1/64
elif [ "$SENSE_SITE" = "strasbourg" ]; then
    # 2001:660:4701:f0a0::/64	2001:660:4701:f0bf::/64
    export BORDER_ROUTER_IP=2001:660:4701:f0af::1/64
else
    echo "Invalid SENSE_SITE value. Please set to 'grenoble' or 'paris'."
fi

export ARCH=iotlab-m3

# values are from 11-26
export DEFAULT_CHANNEL=22
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
