<a name="readme-top"></a>

<p align="center">
  <img src="./images/logo_Logo.png" width="400"/>
</p>

<!-- TABLE OF CONTENTS -->

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

End to end IOT system which collects sensor data and visualize on cloud

![High Level Architecture](./images/architecture.jpeg)

<!-- BUILT WITH -->

## Built With

This section should list any major frameworks/libraries used to bootstrap your project. Leave any add-ons/plugins for the acknowledgements section. Here are a few examples.

* RIOT - Real Time operating system

* [IoT-LAB M3]([IoT-LAB M3 · FIT IoT-LAB](https://www.iot-lab.info/docs/boards/iot-lab-m3/)) MCU boards

* I2C  Protocol

* [CoAP]([Constrained Application Protocol - Wikipedia](https://en.wikipedia.org/wiki/Constrained_Application_Protocol)) - Constrained Application Protocol

* [Grafana](https://grafana.com/)

* [InfluxDB](https://www.influxdata.com/glossary/nosql-database/) - is a time series no sql database designed to handle high write and query loads, primarily used for real-time analytics, monitoring, and IoT applications.

* Amazon EC2
  
  <p align="right">(<a href="#readme-top">back to top</a>)</p>

### Sensor Layer

More details about sensor layer is here :  [Sensor](./docs/SENSOR,md)

- We using M3 boards pressure sensors built in temperature sensor to read temperature data

- Sensor is setup to temperature resolution configuration 101. To Further reduce noise and increase precision by internal averaging. (AVGT2, AVGT1, ABGT0) - 101

- We use **SMA** (Simple Moving Average) technique to reduce noise in the data

- Data is collected and send in bulk to the server

- Board is in **sleep** mode when not reading the sensor data

- Parity bit is added as extra precaution to recognize corrupted data

                                                                                                                   ([back to top](#readme-top))

## Network Layer

More details about sensor layer is here : [Network](./docs/NETWORK,md)