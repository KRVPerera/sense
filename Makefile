clean:
	rm ~/shared/hello-world.elf

hello:
	./hello_world_experiment.sh

sensor-m3:
	./sensor_read_experiment.sh

stop:
	iotlab-experiment stop

checktcp:
	telnet 86.50.252.174 23455

stop_all:
	./scripts/stoppers/stop_all.sh
