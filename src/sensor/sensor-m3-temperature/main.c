#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "thread.h"
#include "ztimer.h"
#include "shell.h"

#include "mutex.h"

#include "lpsxxx.h"
#include "lpsxxx_params.h"

static lpsxxx_t lpsxxx;
static mutex_t lps_lock = MUTEX_INIT;


// Read the lps331p temperature sensor
/* stack memory allocated for the lpsxxx_handler thread */
static char lps331ap_stack[THREAD_STACKSIZE_DEFAULT];

static void *lpsxxx_thread(void *arg)
{
  (void)arg; // avoid a compiler warning

  while(1) {

    mutex_lock(&lps_lock);

    int16_t temp = 0;
    lpsxxx_read_temp(&lpsxxx, &temp);

    if (lpsxxx_read_temp(&lpsxxx, &temp) == LPSXXX_OK) {
      printf("Temperature: %i.%u°C\n", (temp / 100), (temp % 100));
    }

    mutex_unlock(&lps_lock);
    ztimer_sleep(ZTIMER_MSEC, 5000);
  }
  
  return 0;
}

//static const shell_command_t commands[] = {
//
//  /* lps331ap shell command handler */
//  { "lps", "read the lps331ap values", lpsxxx_handler},
//
//  { NULL, NULL, NULL}
//};

int main(void)
{

  lpsxxx_params_t paramts = {
    .i2c  = lpsxxx_params[0].i2c,  \
    .addr = lpsxxx_params[0].addr, \
    .rate = LPSXXX_RATE_1HZ 
  };

  // LPSXXX_RATE_7HZ = 5,        /**< sample with 7Hz, default */
  //   LPSXXX_RATE_12HZ5 = 6,      /**< sample with 12.5Hz */
  //   LPSXXX_RATE_25HZ = 7

  if (lpsxxx_init(&lpsxxx, &paramts) != LPSXXX_OK) {
      puts("Sensor initialization failed");
      return 1;
  }

  if (lpsxxx_enable(&lpsxxx)	!= LPSXXX_OK) {
    puts("Sensor enable failed");
    return 1;
  }

  ztimer_sleep(ZTIMER_MSEC, 1000);

  thread_create(lps331ap_stack, sizeof(lps331ap_stack), THREAD_PRIORITY_MAIN - 1,
      0, lpsxxx_thread, NULL, "lps331p");

  //char line_buf[SHELL_DEFAULT_BUFSIZE];
  //shell_run(commands, line_buf, SHELL_DEFAULT_BUFSIZE);

  return 0;
}
