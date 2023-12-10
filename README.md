[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/KRVPerera/sense/blob/main/README.md">
    <img src="images/logo_Logo_sm.png" alt="Logo" width="200">
  </a>

  <h3 align="center">Sense</h3>

  <p align="center">
    Sensor to Cloud - CoAP enabled system
    <br />
    <a href="https://github.com/KRVPerera/sense"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://www.youtube.com/watch?v=Y-Kq7G6Sz5Q">View Demo</a>
    ·
    <a href="https://github.com/KRVPerera/sense/issues">Report Bug</a>
    ·
    <a href="https://github.com/KRVPerera/sense/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
      <li><a href="#high-level-architecture">High Level Architecture</a></li>
      <li><a href="#sensor-layer">Sensor Layer</a></li>
      <li><a href="#network-layer">Network Layer</a></li>
      <li><a href="#data-management-layer">Data Management Layer</a></li>
      <li><a href="#overview-of-data-flow">Overview of Data Flow</a></li>
      <li><a href="#security">Security</a></li>
      <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
        <ul>
          <li><a href="#server-side">Server side</a></li>
          <li><a href="#testbed-side">Testbed side</a></li>
        </ul>
        <li><a href="#how-to-run-the-project">How to run the project</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#Documentation">Documentation</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## About The Project

### High Level Architecture

![High Level Architecture](./images/archi.png)

### Sensor Layer

More details about sensor layer is here : [docs/Sensor](./docs/SENSOR.md)

- We using M3 boards pressure sensors built in temperature sensor to read temperature data

- Sensor is setup to temperature resolution configuration 101. To Further reduce noise and increase precision by internal averaging. (AVGT2, AVGT1, ABGT0) - 101

- We use **SMA** (Simple Moving Average) technique to reduce noise in the data

- Data is collected and send in bulk to the server

- Board is in **sleep** mode when not reading the sensor data

- Parity bit is added as extra precaution to recognize corrupted data

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Network Layer

More details about network layer is here : [docs/Network](./docs/NETWORK.md)

- We use CoAP request response style application layer protocol.

- CoAP is a **low overhead** protocol designed for **constrained** network nodes.

- It has **Confirmable** mode message communication with server that we use which gets a `ACK` response from the server.

- It provides **re transmission** to mitigate packet loss during transmission. It has a 16 bit message id to help this.

- Runs on UDP protocol reducing overhead on nodes.

- Since it runs on UDP it can intermittently connect and disconnect which by nature of IOT nodes

References

- [The Constrained Application Protocol (CoAP)](https://datatracker.ietf.org/doc/html/rfc7252)
- [Constrained Application Protocol - Wikipedia](https://en.wikipedia.org/wiki/Constrained_Application_Protocol)
- [What is CoAP](https://www.radware.com/security/ddos-knowledge-center/ddospedia/coap/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Data Management Layer

More details about data management layer is here : [docs/Server](./docs/SERVER.md)

- InfluxDB serves as the core Time Series Database (TSDB) in this architecture. It is a NoSQL database optimized for handling time-stamped data efficiently.

- Grafana complements InfluxDB by providing powerful visualization capabilities for time-series data.

- To ensure data integrity, a parity bit is appended to each temperature value during transmission. The EC2 CoAP listener, running as a Docker container, extracts the received data and performs frequent parity checks.

### Overview of Data Flow

1. **Data Ingestion:**
   CoAP data is ingested into the EC2 instance, where the CoAP listener Docker container captures and extracts the temperature values along with parity bits.

2. **Data Storage:**
   Extracted and verified data, is written into InfluxDB for persistent storage.

3. **Data Visualization:**
   Grafana connects to InfluxDB to fetch time-series data and displays it through customizable dashboards.

The integration of InfluxDB and Grafana within the EC2 environment provides a robust foundation for handling, storing, and visualizing time-series data efficiently.

References

- [NoSQL Database - InfluxDB](https://www.influxdata.com/glossary/nosql-database/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Security

- Although we have not focused on this aspect. CoAP protocol it self support secure communication over DTLS by exchanging ECDSA certificates. It is an easy to setup.

- For testing purposes we have opened all the source IPv6 addresses in EC2 instance. but we need to add inbound rules only to allow our CoAP client IPs to reach the server.

- We have made sure only the relevant port for CoAP to open in the server.

- Parity bit serves as data corruption detection. But we can go for CRC like more advance algorithms.

- Data is not encrypted. Even when you use DTLS still from application layer your server and node can decide on a encryption mechanism to secure the data further.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- BUILT WITH -->

### Built With

- [RIOT - Real Time operating system](https://www.riot-os.org/)
- [IoT-LAB M3 · FIT IoT-LAB](https://www.iot-lab.info/docs/boards/iot-lab-m3/) MCU boards
- [I2C Protocol](https://en.wikipedia.org/wiki/I%C2%B2C)
- [CoAP - Constrained Application Protocol](https://en.wikipedia.org/wiki/Constrained_Application_Protocol) - Constrained Application Protocol
- [Grafana](https://grafana.com/)
- [InfluxDB](https://www.influxdata.com/glossary/nosql-database/)
- [Amazon EC2](https://aws.amazon.com/ec2/)
- [Docker](https://www.docker.com/)

    <p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Prerequisites

- You need an account in [FIT IoT Testbed](https://www.iot-lab.info/)
- Get SSH access. [SSH Access : FIT IoT Testbed](https://www.iot-lab.info/docs/getting-started/ssh-access/)
- For firstime use of command line tools you need authentication `iotlab-auth -u <login>`
- Next we recommend to follow our hello example [How to Run Hello | Sense Wiki](https://github.com/KRVPerera/sense/wiki/Running-our-Hello-world-in-F-I-T-IOT%E2%80%90LAB).
- Docker
- 
- Setup the server to receive data from testbed. Please see the installation section.

Check these links to know about the testbed,

-   [Design | FIT IoT Testbed](https://www.iot-lab.info/docs/getting-started/design/)

Check our wiki for more information,

-   [Sense Wiki](https://github.com/KRVPerera/sense/wiki)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Installation

#### Server side

More details about data management layer (server) is here : [docs/Server](https://github.com/KRVPerera/sense/blob/main/docs/SERVER.md)



<p align="right">(<a href="#readme-top">back to top</a>)</p>

#### Testbed side

Testbed already has relevant environment and tool and our make command `make run_mini_project_1` will completely run the sensor layer once you properly set it up according the section below.

If you already tried our [How to Run Hello | Sense Wiki](https://github.com/KRVPerera/sense/wiki/Running-our-Hello-world-in-F-I-T-IOT%E2%80%90LAB) example you can skip 1-5

1. Clone the repo ideally to the home folder in an SSH from end of the IOT test bed
2. If this is your first time, you have to authenticate using `iotlab-auth` command
3. Run this command in the sense folder to get RIOT. `git submodule update --init`
4. Change the site here (SENSE_SITE) in [setup_env.sh#L4 | Sense](https://github.com/KRVPerera/sense/blob/main/scripts/setup_env.sh#L4). Without running the system from the same site we cannot ssh directly into nodes.
5. Border router IP.

    - We are automatically assigning this according the site name you provided in above point 4.
    - But you can do it manually as well.Change the boarder router IP here (BORDER_ROUTER_IP) in [setup_env.sh | Sense](https://github.com/KRVPerera/sense/blob/27b935a44a8a17de54a6b4f463ea0e086fbcb665/scripts/setup_env.sh#L70) according to [IPv6 | FIT IoT Testbed](https://www.iot-lab.info/docs/getting-started/ipv6/)

6. Set the CoAP server IP (amazon in our case) in the terminal using `export COAP_SERVER_IP="[2001:660:4403:497:a417:1216:7ea7:9acb]:5683"`. How to setup the server is explained in our docs [docs/Server.](https://github.com/KRVPerera/sense/blob/4340af737ee8b608d5924ff08c33486e86bc59cc/docs/SERVER.md)
7. Run the command `make run_mini_project_1` from the sense home directory.
8. If the default nodes are busy, change the initial node number here [setup_env.sh#L29 | Sense](https://github.com/KRVPerera/sense/blob/27b935a44a8a17de54a6b4f463ea0e086fbcb665/scripts/setup_env.sh#L29)

> [!TIP]
> Our demo video can be a hand one experience setup for you here [IoT mini project Group 12 | Youtube](https://youtu.be/Y-Kq7G6Sz5Q) video.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### How to run the project

If the server is ready and everything is setup correctly,
Run the command `make run_mini_project_1` from the sense home directory. You will start to see receving data from the server (coap server -> database -> grafana)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- DOCUMENTATION -->

## Documentation

[docs/](docs/README.md)

[doas/SENSOR](docs/SENSOR.md)

[docs/NETWORK](docs/NETWORK.md)

[docs/SERVER](docs/SERVER.md)

[docs/COMPRESSION](docs/COMPRESSION.md)

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

-   [Choose an Open Source License](https://choosealicense.com)
-   [Awesome Badges](https://dev.to/envoy_/150-badges-for-github-pnk)
-   [Best README Template](https://github.com/othneildrew/Best-README-Template)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/KRVPerera/sense.svg?style=plastic
[contributors-url]: https://github.com/KRVPerera/sense/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/KRVPerera/sense.svg?style=plastic
[forks-url]: https://github.com/KRVPerera/sense/network/members
[issues-shield]: https://img.shields.io/github/issues/KRVPerera/sense.svg?style=plastic
[issues-url]: https://github.com/KRVPerera/sense/issues
[license-shield]: https://img.shields.io/github/license/KRVPerera/sense.svg?style=plastic
[license-url]: https://github.com/KRVPerera/sense/blob/master/LICENSE.txt
