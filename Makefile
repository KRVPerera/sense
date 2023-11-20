hello:
	./hello_world_experiment.sh

sensor-m3:
	./sensor_read_experiment.sh

stop:
	iotlab-experiment stop

stop_all:
	./scripts/stoppers/stop_all.sh

test_coap_server:
	aiocoap-client coap://[2001:660:5307:3107:a4a9:dc28:5c45:38a9]/riot/board iotlab-m3

ping_to_google:
	./scripts/ping_to_google.sh

gnrc_border_router:
	./scripts/gnrc_border_router.sh

coap_server:
	./scripts/coap_server.sh