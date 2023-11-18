all: setup_border_router setup_hop_node

setup_border_router:
	./gnrc_border_router.sh

setup_hop_node:
	./gnrc_networking.sh

check_interfaces:
	ip-6 route

tap7:
	sudo ethos_uhcpd.py m3-362 tap0 2001:660:3207:04c7::1/64

stop:
	iotlab-experiment stop

con_node2:
	nc m3-361 20000


test_coap:
	./coap_test.sh

