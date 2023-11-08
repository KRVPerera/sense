Using Sensors in M3 Board
================

This application is used to showcase how to interact with sensors avaible in the IoT-Lab M3 Board. This will read and display values of these sensors.

The IoT-LAB M3 board sensors:

- lps331ap: a temperature and atmospheric pressure sensor
    - temperature|pressure values will be read with the shell command `lps`
- l3g4200d: a gyroscope
    - 
- lsm303dlhc: an accelerometer and magnetometer
    - Values will be read continuesly 500ms with the shell command `lsm start`. And will stop with `lsm stop`.
- isl29020: a light sensor
    -

Usage
=====

Build, flash and start the application:
```bash
export BOARD=iotlab-m3
make
make IOTLAB_NODE=auto flash
make IOTLAB_NODE=auto term
```
 or

 Run

 ```bash
 ./sensor.sh
 ```

Setup
=====

1. Submit an experiment using the following command:

```bash
iotlab-experiment submit -n "group-12" -d 120 -l 1,archi=m3:at86rf231+site=saclay
```
choose your site(grenoble|lille|saclay|strasbourg)

2. Wait for the experiment to be in the Running state:
```bash
!iotlab-experiment wait --timeout 30 --cancel-on-timeout
```

3. Get the experiment nodes list:
```bash
iotlab-experiment --jmespath="items[*].network_address | sort(@)" get --nodes
```

Output examples
=====

1. Reading the temperature and atmospheric pressure sensor

Connecting to the serial port of m3 board by running `make IOTLAB_NODE=auto term`. It will open up the RIOT shell.

Sample output:

```bash
socat - tcp:m3-11:20000 
lps
lps
usage: lps <temperature|pressure>
> lps temperature
lps temperature
Temperature: 42.14°C
> lps pressure
lps pressure
Pressure: 988hPa
> 
```

2. Reading the accelerometer and magnetometer sensor

Connecting to the serial port of m3 board by running `make IOTLAB_NODE=auto term`. It will open up the RIOT shell.

Sample output:

```bash
socat - tcp:m3-11:20000 
> lsm start
lsm start
Accelerometer x: 696 y: 124 z: -292
Magnetometer x: -215 y: -76 z: -104
> Accelerometer x: 692 y: 128 z: -292
Magnetometer x: -213 y: -77 z: -105
Accelerometer x: 692 y: 128 z: -284
Magnetometer x: -214 y: -75 z: -105
Accelerometer x: 700 y: 132 z: -292
Magnetometer x: -213 y: -76 z: -104
> 
```

