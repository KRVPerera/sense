hello:
	./hello_world_experiment.sh

sensor-m3:
	./sensor_read_experiment.sh

stop:
	iotlab-experiment stop

stop_all:
	./scripts/stoppers/stop_all.sh

test_coap_server:
	aiocoap-client coap://[2001:660:3207:4c1:1711:6b10:65fd:bd36]/riot/board iotlab-m3
