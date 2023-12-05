hello:
	./scripts/hello_world_experiment.sh

run_mini_project_1:
	./scripts/mini_project1.sh

run_sensor:
	./scripts/sensor_read_experiment.sh

sense:
	./scripts/sensor-connected.sh

stop:
	iotlab-experiment stop

stop_all:
	./scripts/stoppers/stop_all.sh

test_coap_server:
	aiocoap-client coap://[2001:660:5307:3107:a4a9:dc28:5c45:38a9]/riot/board iotlab-m3

# run border router and network node, you get a shell to the network node where you can ping public ipv6 addresses
ping_to_google:
	./scripts/ping_to_google.sh

# run border router node
gnrc_border_router:
	./scripts/gnrc_border_router.sh

# run border router and coap server in the same network
coap_server:
	./scripts/coap_server.sh

# run coap_server in separate shell
coap_test:
	./scripts/coap_test.sh

# Current test carried out after running coap_server in separate shell
coap_client_test:
	./scripts/coap_client_test.sh

# same as about shortenned work for faster dev
coap:
	./scripts/coap_client_test.sh

clean_all: clean
	./scripts/clean_all.sh

clean:
	rm ~/shared/firmware/*.elf
	find ./src -type d -name bin -exec rm -rf {} +
