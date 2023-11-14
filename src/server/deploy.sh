#!/usr/bin/env bash

repo=`pwd | rev | cut -d '/' -f 1 |rev`
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
			if [[ -z $2 ]];
			then
				print_error "--mode needs a value"
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

    docker run -v ~/.aws/credentials:/root/.aws/credentials \
            --network host -p 5683:5683 coap-server 
}

function run_server()
{
    docker run -v ~/.aws/credentials:/root/.aws/credentials \
            --network host -p 5683:5683 coap-server 
}

function deploy_lambda()
{
    sam deploy --template-file lambda_handler/template.yaml
}

function grafana_start()
{
	sudo /bin/systemctl daemon-reload
 	sudo /bin/systemctl enable grafana-server
 	sudo /bin/systemctl start grafana-server
}

if [ $mode == "lambda" ];then
    deploy_lambda
    if [[ $build_status == 'success' ]];then
		print_title "successfully deployed lambda function and script is exited"
		exit 0
	else
		print_title "deploy failed"
		exit -1
	fi
fi

if [ $mode == "server" ];then
	grafana_start
    build_and_deploy_server
    if [[ $build_status == 'success' ]];then
		print_title "successfully deployed the server and script is exited"
		exit 0
	else
		print_title "deploy failed"
		exit -1
	fi
fi

if [ $mode == "run-server" ];then
    run_server
    if [[ $build_status == 'success' ]];then
		print_title "successfully deployed the server and script is exited"
		exit 0
	else
		print_title "deploy failed"
		exit -1
	fi
fi

if [ $mode == "all" ];then
	grafana_start
    deploy_lambda
	build_and_deploy_server
    if [[ $build_status == 'success' ]];then
		print_title "successfully deployed the system and script is exited"
		exit 0
	else
		print_title "deploy failed"
		exit -1
	fi
fi