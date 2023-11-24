# Network

Our project uses IPv6 (TCP/IP) stack for connectivity between nodes and connectivity to our server which handles most of the data.



## Simple Architecture

Certainly, KRV. Here's a visual representation of the flow from a sensor node to a CoAP server through a border router, illustrated using Markdown:

markdownCopy code

Sensor Node
    |
    | Wireless `802.15.4`
    V
Border Router
    |
    | Wired - `ETHOS` (Ehternet Over Serial)
    V
CoAP Server



- Border Router [Setting up border router](https://github.com/KRVPerera/sense/wiki/Setting-up-border-router)

- Network availability for sensor node

- CoAP protocol



## CoAP protocol for application layer

- We send each in ´Confirmable´ mode

- 









## References

- [CoAP server with public IPv6 network on M3 nodes · FIT IoT-LAB](https://www.iot-lab.info/learn/tutorials/riot/riot-coap-m3/)

- [Constrained Application Protocol - Wikipedia](https://en.wikipedia.org/wiki/Constrained_Application_Protocol)

- 
