#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "thread.h"
#include "ztimer.h"
#include "shell.h"

#include "mutex.h"

#include "lpsxxx.h"
#include "lpsxxx_params.h"


#include "lsm303dlhc.h"
#include "lsm303dlhc_params.h"

static lpsxxx_t lpsxxx;
static lsm303dlhc_t lsm303dlhc;

static mutex_t lsm_lock = MUTEX_INIT_LOCKED;

/* stack memory allocated for the lsm303dlhc thread */
static char lsm303dlhc_stack[THREAD_STACKSIZE_MAIN];

static void *lsm303dlhc_thread(void *arg)
{
    (void)arg;

    while (1) {
        /* Acquire the mutex here */
        mutex_lock(&lsm_lock);

        /* Read the accelerometer/magnetometer values here */
        lsm303dlhc_3d_data_t mag_value;
        lsm303dlhc_3d_data_t acc_value;
        lsm303dlhc_read_acc(&lsm303dlhc, &acc_value);
        printf("Accelerometer x: %i y: %i z: %i\n",
               acc_value.x_axis, acc_value.y_axis, acc_value.z_axis);
        lsm303dlhc_read_mag(&lsm303dlhc, &mag_value);
        printf("Magnetometer x: %i y: %i z: %i\n",
               mag_value.x_axis, mag_value.y_axis, mag_value.z_axis);

        /* Release the mutex here */
        mutex_unlock(&lsm_lock);
        
        ztimer_sleep(ZTIMER_MSEC, 500);
    }

    return 0;
}

static void _lsm303dlhc_usage(char *cmd)
{
    printf("usage: %s <start|stop>\n", cmd);
}

static int lsm303dlhc_handler(int argc, char *argv[])
{
    if (argc < 2) {
        _lsm303dlhc_usage(argv[0]);
        return -1;
    }

    if (!strcmp(argv[1], "start")) {
        mutex_unlock(&lsm_lock);
    }
    else if (!strcmp(argv[1], "stop")) {
        mutex_trylock(&lsm_lock);
    }
    else {
        _lsm303dlhc_usage(argv[0]);
        return -1;
    }

    return 0;
}

static void _lpsxxx_usage(char *cmd)
{
    printf("usage: %s <temperature|pressure>\n", cmd);
}

static int lpsxxx_handler(int argc, char *argv[])
{
    if (argc < 2) {
        _lpsxxx_usage(argv[0]);
        return -1;
    }

    if (!strcmp(argv[1], "temperature")) {
        int16_t temp = 0;
        lpsxxx_read_temp(&lpsxxx, &temp);
        printf("Temperature: %i.%u°C\n", (temp / 100), (temp % 100));
    }
    else if (!strcmp(argv[1], "pressure")) {
        uint16_t pres = 0;
        lpsxxx_read_pres(&lpsxxx, &pres);
        printf("Pressure: %uhPa\n", pres);
    }
    else {
        _lpsxxx_usage(argv[0]);
        return -1;
    }

    return 0;
}

static const shell_command_t commands[] = {
    /* lsm303dlhc shell command handler */
    { "lsm", "start/stop reading accelerometer values", lsm303dlhc_handler },

    /* lps331ap shell command handler */
    { "lps", "read the lps331ap values", lpsxxx_handler },

    { NULL, NULL, NULL}
};

int main(void)
{
    lpsxxx_init(&lpsxxx, &lpsxxx_params[0]);
    lsm303dlhc_init(&lsm303dlhc, &lsm303dlhc_params[0]);
    
    thread_create(lsm303dlhc_stack, sizeof(lsm303dlhc_stack), THREAD_PRIORITY_MAIN - 1,
                  0, lsm303dlhc_thread, NULL, "lsm303dlhc");

    char line_buf[SHELL_DEFAULT_BUFSIZE];
    shell_run(commands, line_buf, SHELL_DEFAULT_BUFSIZE);

    return 0;
}
