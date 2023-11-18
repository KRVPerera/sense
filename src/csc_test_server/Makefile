telnet_tcp:
	telnet 86.50.252.174 23455

start:
	sudo systemctl start tcp_server.service

stop:
	sudo systemctl stop tcp_server.service

status:
	sudo systemctl status tcp_server.service

logs:
	journalctl -f -u tcp_server.service

restart:
	sudo systemctl restart tcp_server.service

flask:
	curl http://86.50.252.174:5001/messages

coap_server:
	python3 simple_coap_server.py

coap_test_hello_get:
	python3 coap_hello_client.py

coap_test_message_put:
	python3 simple_coap_message_client.py
