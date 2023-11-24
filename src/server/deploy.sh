#!/usr/bin/env bash

function help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Build and deploy script for CoAP server with optional services."

    echo -e "\nOptions:"
    echo "  --mode MODE   Set the deployment mode. Default: 'all'."
    echo "                Available modes:"
    echo "                  - all    : Build and deploy server, start Grafana, and InfluxDB."
    echo "                  - server : Build and deploy server only."

    echo -e "\n  -h, --help    Display this help message."

    echo -e "\nExample:"
    echo "  $0 --mode server  # Build and deploy the server only."

    echo -e "\nNote:"
    echo "  - Grafana and InfluxDB are started only in 'all' mode, not in 'server' mode."
}

repo=$(pwd | rev | cut -d '/' -f 1 | rev)
mode="all"

echo "================================================================================================"
echo "         					BUILD_AND_DEPLOY ($repo) "
echo "================================================================================================"

while [ ! -z $1 ]; do
    case "$1" in
        -h|--help)
            help
            exit 0
        ;;
        --mode)
            if [[ -z $2 ]]; then
                echo "--mode needs a value"
                exit 1
            else
                mode=$2
                shift
            fi
        ;;
    esac
    shift
done

function build_and_deploy_server()
{
    docker build -t coap-server . 

    docker run \
            --network host -p 5683:5683 coap-server 
}

function grafana_start() {
    if ! pgrep -x "grafana-server" > /dev/null; then
        sudo /bin/systemctl daemon-reload
        sudo /bin/systemctl enable grafana-server
        sudo /bin/systemctl start grafana-server
    else
        echo "Grafana is already running."
    fi
}

function influxdb_start() {
    if ! pgrep -x "influxd" > /dev/null; then
        sudo service influxdb start
    else
        echo "InfluxDB is already running."
    fi
}

if [ $mode == "all" ];then
	grafana_start
	influxdb_start
    build_and_deploy_server
    if [[ $build_status == 'success' ]];then
		echo "successfully deployed the server and script is exited"
		exit 0
	else
		echo "deploy failed"
		exit -1
	fi
fi

if [ $mode == "server" ];then
    build_and_deploy_server
    if [[ $build_status == 'success' ]];then
		echo "successfully deployed the server and script is exited"
		exit 0
	else
		echo "deploy failed"
		exit -1
	fi
fi