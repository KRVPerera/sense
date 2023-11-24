
---

# Server 

## Overview

This project implements a cloud-based solution for handling CoAP data. The server listens for CoAP data, writes it into an InfluxDB database, and visualizes the data using Grafana. The implementation utilizes **Docker for easy deployment**, and the entire system can be deployed on an AWS EC2 instance.

## Prerequisites

- AWS account with EC2 access
- Docker installed on the EC2 instance

## Setting Up EC2 and Assigning a Public IPv6 Address

1. **Create an EC2 Instance**

   - Launch an EC2 instance with a suitable AMI (Amazon Machine Image).
   - Ensure that the instance has the necessary permissions to interact with other AWS services.

2. **Assign a Public IPv6 Address**

   - Follow the [AWS Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html#ipv6-assign-instance) to assign a public IPv6 address to your EC2 instance.

3. **Configure Inbound Rules for CoAP**

   - Go to the AWS Management Console.
   - Navigate to the EC2 Dashboard.
   - Select your instance, go to the "Security" tab, and click on the associated Security Group.
   - In the Security Group settings, add an inbound rule for UDP at port 5683 for IPv6.

     ```plaintext
     Type: Custom UDP Rule
     Protocol: UDP
     Port Range: 5683
     Source: ::/0
     ```

     This allows incoming UDP traffic on port 5683 from any IPv6 address.
     
    - Note for Testing:
    For testing purposes, all IPv6 addresses are allowed (::/0). In a production environment, consider limiting access by applying a range of IPs.
4. **Configure Inbound Rules for Grafana**

   - Add an inbound rule for TCP at port 3000 for IPv4.

     ```plaintext
     Type: Custom TCP Rule
     Protocol: TCP
     Port Range: 3000
     Source: 0.0.0.0/0
     ```

     This allows incoming TCP traffic on port 3000 from any IPv4 address.
    - Note for Testing:
    For testing purposes, all IPv4 addresses are allowed (0.0.0.0/0). In a production environment, consider limiting access by applying a range of IPs.
## Setting Up Grafana and InfluxDB

1. **Install InfluxDB and Grafana**

   - [Install InfluxDB](https://docs.influxdata.com/influxdb/v1.8/introduction/install/)
   - [Install Grafana](https://grafana.com/docs/grafana/latest/installation/)

2. **Start Grafana**

   - Ensure Grafana is installed on your system.
   - Start Grafana:

     ```bash
     sudo systemctl enable grafana-server
     sudo systemctl start grafana-server
     ```

   - Access Grafana through `http://<public-ip>:3000/`.

     - Default credentials:
       - Username: `admin`
       - Password: `admin`

   - Upon the first login, Grafana will prompt you to change the password.

3. **Start InfluxDB**

   - Ensure InfluxDB is installed on your system.
   - Start InfluxDB:

     ```bash
     sudo service influxdb start
     ```

   - Follow the [InfluxDB Documentation](https://docs.influxdata.com/influxdb/v1.8/introduction/get-started/) to get started.

## Running the CoAP Server using Docker

1. **Clone the Repository**

   ```bash
   git clone <repository_url>
   cd <repository_directory>/src/server
   ```

2. **Build and Deploy the CoAP Server**

   ```bash
   ./deploy.sh --mode server
   ```

   This script builds the CoAP server Docker container and deploys it. It also starts Grafana and InfluxDB if the mode is set to `all`.

## Usage: Grafana with InfluxDB


1. **Access Grafana Dashboard**

   - Open your web browser and go to `http://<public-ip>:3000/`.
   - Log in to Grafana using the default credentials (admin/admin).

2. **Add InfluxDB Data Source**

   - Select "Data Sources."
   - Click on "Add your first data source."
   - Choose "InfluxDB" from the list of available data sources.

3. **Configure InfluxDB Connection**

   - Set the following parameters:

     - **Name:** Give your data source a name.
     - **Type:** Select "InfluxDB."
     - **HTTP URL:** Set the URL to your InfluxDB instance, `http://localhost:8086`.
     - **InfluxDB Details:** Provide InfluxDB details including `Database name`, `Username`, `Password`. (This need to be defined in the [configuration.py](../src/server/configuration.py) file).

   - Click on "Save & Test" to verify the connection.

4. **Create a Dashboard**

   - Click on the "Dashboard" icon in the left sidebar to create a new dashboard.
   - Select the influxDB data source created earlier.
   - Click on "Add Panel" and choose "Graph."

5. **Query InfluxDB for Time-Series Data**

   - In the "Query" tab, set the measurement and field to visualize from your InfluxDB database.

     - **Measurement:** `temperature`.
     - **Field:** `value`.

   - Set the time range to view your time-series data.

This will setup the Grafana dashboard visualizing time-series data from your InfluxDB database.


## InfluxDB Database Architecture


- **Database Name:** `dht`
- **Measurement Name:** `temperature`
