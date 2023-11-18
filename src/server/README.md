SENSE Server
============

Cloud implementation of the project. The server will listens to the CoAP data and write it into the database and visualize it. 

This contains simple-to-deploy set of micro services which can funnel CoAP data into AWS EC2 instance.

### Example view of Visualizer

![Visualizer](../../images/visualizer.png)

### Overview of Data & Technology Flow

1. Data will ingest via CoAP into an EC2 Instance with a Static IPv6 address.
2. A python based script via Docker is run as a CoAP listener that spits the CoAP data into an InfluxDB database. 
3. Grafana is integrated with InfluxDB database and visualize the stats

### Usage

All the commands are written in shell scripts. Use the `.deploy.sh` shell script to deploy and run the server components. script snables to change the modes and build and run different components of the stack.

command:
```./deploy.sh --mode <mode-selection>```

mode-selection
1. `server` - to build and deploy the CoAP listener docker container
2. `lambda` - to build and deploy the lambda function
3. `all` - to build the whole system

### Code explained

1. CoAP data [ingester](./coap_server.py), written in python and Docker will stream the input data direclty into a SQS queue.
This ingestor will do no data validation in any way. It will inform the use that the data is received, This does support the CoAP .well-known/core feature set at its basics.

2. CoAP data ingested will need to conform to some pre-defined standard format. After successfully ingested data from CoAP and saved/streamed to a highly scalable queued location (SQS) and  informed the user that data is received, it will need to process this data. We use AWS Lambda serveless stack with python to run on a regular batchwise processing (once every 10 dtaa points) to check if there are any messages in the queue, and to process them if there are.

4. Inside this lambda, it will need to do a few things...
First, look at the sequence number and the device id and verify.
Then, look if there is an IoT Device with that Unique ID, if not, create it in the database.

5. Then finally, any properties from the data packet part will be pushed as metrics into the database and hence will be displayed in Grafana visualizer.


### Encryption in transit and device authentication

(TODO)

### Grafana

#### Please execute the following statements to configure grafana to start automatically using systemd
 sudo /bin/systemctl daemon-reload
 sudo /bin/systemctl enable grafana-server
#### Starting grafana-server by executing
 sudo /bin/systemctl start grafana-server

 Grafana can be access through: `http://<public-ip>:3000/`
