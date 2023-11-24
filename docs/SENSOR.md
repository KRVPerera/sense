# Sensor Layer

In this project we use iot-lab m3 boards provided by FIT IOT-LAB which has 4 different types of sensors mounted to it. They are,

- The **light** sensor (ISL29020): This measures ambient light intensity in lux.  
  
  - [ISL29020](https://www.iot-lab.info/assets/misc/docs/iot-lab-m3/ISL29020.pdf)
  
  - [ISL29020 light sensor driver](https://doc.riot-os.org/group__drivers__isl29020.html)

- The **pressure** and **temperature** sensor (LPS331AP): This measures atmospheric pressure in hPa.  
  
  - [LPS331AP](https://www.iot-lab.info/assets/misc/docs/iot-lab-m3/LPS331AP.pdf)
  - [LPS331AP/LPS25HB/LPS22HB Pressure Sensors Driver](https://doc.riot-os.org/group__drivers__lpsxxx.html)

- The **accelerometer/magnetometer** (LSM303DLHC): This provides feedback on an object’s acceleration, and can be used to detect movement. By determining a threshold, it generates a change of state on one of the MCU’s digital inputs/outputs in order to create an interrupt, which can be used to bring the MCU out of standby mode.  
  
  - [LSM303DLHC](https://www.iot-lab.info/assets/misc/docs/iot-lab-m3/LSM303DLHC.pdf)
  - [LSM303DLHC 3D accelerometer/magnetometer driver](https://doc.riot-os.org/group__drivers__lsm303dlhc.html)

- The **gyroscope** (L3G4200D): This measures the orientation of an object in space and can be used, for example, to determine the orientation of the screen of a tablet or a smartphone.  
  
  - [L3G4200D](https://www.iot-lab.info/assets/misc/docs/iot-lab-m3/L3G4200D.pdf)
  - [L3G4200D gyroscope driver](https://doc.riot-os.org/group__drivers__l3g4200d.html)

In our project we used only the LPS331AP sensor to measure temperature values.

## IOT-LAB M3 board architecture

![IOT test bed m3 architecture | 500](../images/m3-archi.png)

More details about IOT-LAB M3 board can be found here:  [IoT-LAB M3 · FIT IoT-LAB](https://www.iot-lab.info/docs/boards/iot-lab-m3/)

## Noise in temperature readings

Noise in sensor readings refers to unwanted or random variations in the data collected by sensors. This noise can be caused by various factors and can have a significant impact on the accuracy and reliability of the sensor readings. Here are some common sources of noise in IoT sensor data.

- Environment factors.

- Fluctuations in the power supply to the sensors can result in variations in the sensor readings.

- Over time, sensors may degrade or drift, leading to changes in their performance and introducing noise into the readings.

- Issues in signal processing or during data transmission can introduce noise into the sensor readings. This could be due to poor quality communication channels or interference during data transmission.

- External electromagnetic fields or radio frequency signals can interfere with the signals from sensors, leading to inaccurate readings.

## Noise reduction technique we used

To eliminate those noises we implemented moving averaging filtering method.

Moving average filtering is a common technique used in signal processing and data analysis to smooth out fluctuations or noise in a time series data set. It is particularly useful in situations where the data contains random variations that may obscure underlying trends or patterns. Moving average filtering works by calculating the average of a set of consecutive data points over a specified window or period, and this average value is then used to represent the smoothed data. 

There are different variations of moving averages, including:

- **Simple Moving Average (SMA):** All data points in the window are given equal weight. (In our project we used this method)

- **Weighted Moving Average (WMA):** Assigns different weights to different data points within the window, giving more importance to certain points.

- **Exponential Moving Average (EMA):** Gives more weight to recent data points and less weight to older data points, allowing for a quicker response to changes in the data.

In our project we used Simple Moving Average Method with window size equal to 5.

[Moving average method implementation](https://github.com/KRVPerera/sense/blob/d57dd8540bc15ae0ad9e885204da4558fc1d42b5/src/sensor/sensor-connected/main.c#L159C7-L180C1)

## Data Resilience

To ensure that the exact data we sent received to the server, we used a parity bit after the each temperature value. When the data is received by the CoAP cloud server, the server extracts the data, including the parity bit assigned to each temperature value. The server then performs a parity check, verifying the integrity of each temperature value. If a discrepancy is detected, indicating that the data has been corrupted during transmission, the server discards the corrupted data to ensure the accuracy and reliability of the received information.

### Parity bit

There are two common types of parity:

1. **Even Parity:**
   
   - In even parity, the total number of bits set to 1 in a given set of bits, including the parity bit, is made even.
   - If the number of 1s is already even, the parity bit is set to 0. If the number of 1s is odd, the parity bit is set to 1.

2. **Odd Parity:**
   
   - In odd parity, the total number of bits set to 1 is made odd.
   - If the number of 1s is already odd, the parity bit is set to 0. If the number of 1s is even, the parity bit is set to 1.

In our project we have used odd parity.

[Parity bit calculator](https://github.com/KRVPerera/sense/blob/d57dd8540bc15ae0ad9e885204da4558fc1d42b5/src/sensor/sensor-connected/main.c#L118C1-L132C2)



## Power optimization

- In our project, the communication between the sensor and the processor is facilitated through the utilization of the I2C interface in a low-power mode. 

- Also, To conserve energy, we employ the sleep method from the ztimer module during periods when temperature values are not being sensed.

- To further optimize power consumption, we have implemented a strategy where individual temperature values are not immediately sent to the server, as this process tends to be energy-intensive due to networking operations. Instead, we have implemented a buffering mechanism, capturing and storing 10 temperature values at one-second intervals. Once the buffer reaches a capacity of 10 values, we initiate the transmission of this batch to the server via a border router, utilizing the CoAP protocol. This approach helps minimize power usage during communication and contributes to the overall energy efficiency of the system.
