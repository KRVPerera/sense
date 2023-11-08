# sense
End to end IOT system which collects sensor data and visualize on cloud

## Sensor Layer

### Sensors

#### M3 - [IoT-LAB M3 · FIT IoT-LAB](https://www.iot-lab.info/docs/boards/iot-lab-m3/)
4 sensors connected to the MCU via the **I2C** bus are embedded into the IoT-LAB M3 board:

- the **light** sensor: this measures ambient light intensity in lux.  [ISL29020](https://www.iot-lab.info/assets/misc/docs/iot-lab-m3/ISL29020.pdf)
- the **pressure** and **temperature** sensor: this measures atmospheric pressure in hPa.  [LPS331AP](https://www.iot-lab.info/assets/misc/docs/iot-lab-m3/LPS331AP.pdf)
- the **accelerometer/magnetometer**: this provides feedback on an object’s acceleration, and can be used to detect movement. By determining a threshold, it generates a change of state on one of the MCU’s digital inputs/outputs in order to create an interrupt, which can be used to bring the MCU out of standby mode.  [LSM303DLHC](https://www.iot-lab.info/assets/misc/docs/iot-lab-m3/LSM303DLHC.pdf)
- the **gyroscope**: this measures the orientation of an object in space and can be used, for example, to determine the orientation of the screen of a tablet or a smartphone.  [L3G4200D](https://www.iot-lab.info/assets/misc/docs/iot-lab-m3/L3G4200D.pdf)

#### Board - # Nordic [Nordic nRF52840DK · FIT IoT-LAB](https://www.iot-lab.info/docs/boards/nordic-nrf52840dk/) -
- temperature and humidity sensor - [HTS221](https://www.st.com/resource/en/datasheet/hts221.pdf)
- an atmospheric pressure sensor  [LPS22HB](https://www.st.com/resource/en/datasheet/dm00140895.pdf)
- an accelerometer sensor  [LSM6DSL](https://www.st.com/resource/en/datasheet/lsm6dsl.pdf)
- an accelerometer sensor  [LSM303AGR](https://www.st.com/resource/en/datasheet/lsm303agr.pdf)

#### Zigduino - [Zigduino · FIT IoT-LAB](https://www.iot-lab.info/docs/boards/zigduino/)
- **Zigduino (atmega128rfa1)**: a basic Zigduino nodes with embedded sensors
    - Primary serial port (console output): **57600 bauds**
    - Sensors
        - [Grove Temperature Humidity sensor](https://wiki.seeedstudio.com/Grove-Temperature_and_Humidity_Sensor_Pro/) (pin 14, A0)
        - [Grove Light sensor](https://wiki.seeedstudio.com/Sensor_light/) (pin 15, A1)
        - [Grove Loudness sensor](https://wiki.seeedstudio.com/Grove-Loudness_Sensor/) (pin 16, A2)
        - [Grove PIR Motion sensor](https://wiki.seeedstudio.com/Grove-PIR_Motion_Sensor/) (pin 4, D4)

#### ST B-L475E-IOT01A - [ST B-L475E-IOT01A · FIT IoT-LAB](https://www.iot-lab.info/docs/boards/st-b-l475e-iot01a/)

- a temperature and humidity sensor  [HTS221](https://www.st.com/resource/en/datasheet/hts221.pdf)
- an atmospheric pressure sensor  [LPS22HB](https://www.st.com/resource/en/datasheet/dm00140895.pdf)
- an accelerometer sensor  [LSM6DSL](https://www.st.com/resource/en/datasheet/lsm6dsl.pdf)


## Network Layer


### Publish Subscriber channel - phase 2
[MQTT · FIT IoT-LAB](https://www.iot-lab.info/docs/tools/mqtt-broker/)

### Test server

### Deployment server

AWS

## Data 

>[!WARNING]
>not sure if accelerometer, gyroscopes have a meaning. 
>I can see some boards may be connected to robots or moving platforms.. But not sure if we have access to those yet.

#### Sensor data
- temperature
- humidity
- atmospheric pressure