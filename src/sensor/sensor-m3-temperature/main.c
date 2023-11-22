#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "thread.h"
#include "ztimer.h"
#include "shell.h"

#include "mutex.h"

#include "lpsxxx.h"
#include "lpsxxx_params.h"

typedef struct {
    char buffer[128];
    mutex_t lock;
} data_t;
static data_t data;

static lpsxxx_t lpsxxx;
// static mutex_t lps_lock = MUTEX_INIT;

#define LPSXXX_REG_RES_CONF (0x10)
#define LPSXXX_REG_CTRL_REG2 (0x21)
#define DEV_I2C (dev->params.i2c)
#define DEV_ADDR (dev->params.addr)
#define DEV_RATE (dev->params.rate)

int write_register_value(const lpsxxx_t *dev, uint16_t reg, uint8_t value)
{
  i2c_acquire(DEV_I2C);
  if (i2c_write_reg(DEV_I2C, DEV_ADDR, reg, value, 0) < 0)
  {
    i2c_release(DEV_I2C);
    return -LPSXXX_ERR_I2C;
  }
  i2c_release(DEV_I2C);

  return LPSXXX_OK; // Success
}

int temp_sensor_write_CTRL_REG2_value(const lpsxxx_t *dev, uint8_t value)
{
  return write_register_value(dev, LPSXXX_REG_CTRL_REG2, value);
}

int temp_sensor_write_res_conf(const lpsxxx_t *dev, uint8_t value)
{
  return write_register_value(dev, LPSXXX_REG_RES_CONF, value);
}

// Read the lps331p temperature sensor
/* stack memory allocated for the lpsxxx_handler thread */
static char lps331ap_stack[THREAD_STACKSIZE_DEFAULT];

static void *lpsxxx_thread(void *arg)
{
  (void)arg; // avoid a compiler warning

  while (1)
  {

    mutex_lock(&data.lock);

    int16_t temp = 0;
    if (lpsxxx_read_temp(&lpsxxx, &temp) == LPSXXX_OK) {
      sprintf(data.buffer, "Temperature: %i.%u°C\n", (temp / 100), (temp % 100));
    }

    mutex_unlock(&data.lock);
    ztimer_sleep(ZTIMER_MSEC, 5000);
  }

  return 0;
}

int temp_sensor_reset(void)
{
  lpsxxx_params_t paramts = {
      .i2c = lpsxxx_params[0].i2c,
      .addr = lpsxxx_params[0].addr,
      .rate = LPSXXX_RATE_7HZ};
  // .rate = lpsxxx_params[0].rate
  // LPSXXX_RATE_7HZ = 5,        /**< sample with 7Hz, default */
  //   LPSXXX_RATE_12HZ5 = 6,      /**< sample with 12.5Hz */
  //   LPSXXX_RATE_25HZ = 7

  if (lpsxxx_init(&lpsxxx, &paramts) != LPSXXX_OK)
  {
    puts("Sensor initialization failed");
    return 0;
  }

  // 7       6543    2          1      0
  // BOOT RESERVED SWRESET AUTO_ZERO ONE_SHOT
  //  1      0000   1      0            0
  // 44
  if (temp_sensor_write_CTRL_REG2_value(&lpsxxx, 0x44) != LPSXXX_OK)
  {
    puts("Sensor reset failed");
    return 0;
  }

  ztimer_sleep(ZTIMER_MSEC, 5000);

  // 0x40 -- 01000000
  // AVGT2 AVGT1 AVGT0 100 --  Nr. internal average : 16
  if (temp_sensor_write_res_conf(&lpsxxx, 0x40) != LPSXXX_OK)
  {
    puts("Sensor enable failed");
    return 0;
  }

  if (lpsxxx_enable(&lpsxxx) != LPSXXX_OK)
  {
    puts("Sensor enable failed");
    return 0;
  }

  ztimer_sleep(ZTIMER_MSEC, 1000);
  return 1;
}

int main(void)
{
  if (temp_sensor_reset() == 0) {
    puts("Sensor failed");
    return 1;
  }

  thread_create(lps331ap_stack, sizeof(lps331ap_stack), THREAD_PRIORITY_MAIN - 1,
                0, lpsxxx_thread, NULL, "lps331p");

  while (1) {
    /* safely read the content of the buffer here */
    mutex_lock(&data.lock);
    printf("Hello: %s\n", data.buffer);
    mutex_unlock(&data.lock);

    ztimer_sleep(ZTIMER_MSEC, 30000);
  }

  return 0;
}
