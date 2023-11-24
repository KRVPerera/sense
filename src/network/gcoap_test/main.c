/*
 * Copyright (c) 2015-2016 Ken Bannister. All rights reserved.
 *
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License v2.1. See the file LICENSE in the top level
 * directory for more details.
 */

/**
 * @ingroup     examples
 * @{
 *
 * @file
 * @brief       gcoap example
 *
 * @author      Ken Bannister <kb2ma@runbox.com>
 *
 * @}
 */

#include <stdio.h>
#include "msg.h"

#include "net/gcoap.h"
#include "net/ipv6/addr.h"
#include "net/sock/util.h"
#include "shell.h"
#include "net/utils.h"
#include "od.h"
#include "ztimer.h"
#include "mutex.h"

#include "gcoap_example.h"


#define GET_TOPIC CORE
#define MAIN_QUEUE_SIZE (4)
static msg_t _main_msg_queue[MAIN_QUEUE_SIZE];

static const shell_command_t shell_commands[] = {
    {"coap", "CoAP example", gcoap_cli_cmd},
    {NULL, NULL, NULL}};

void setup_coap_client(void) {
    msg_init_queue(_main_msg_queue, MAIN_QUEUE_SIZE);
    ztimer_sleep(ZTIMER_MSEC, 1000);
}


static mutex_t data_lock = MUTEX_INIT;


static void *coap_server_connect(void *arg)
{
  (void)arg; // avoid a compiler warning

  while(1) {

    mutex_lock(&data_lock);

    send_coap_get_request(CORE);
    ztimer_sleep(ZTIMER_MSEC, 1000);

    send_coap_get_request(BOARD);

    ztimer_sleep(ZTIMER_MSEC, 1000);

    gcoap_post("asd", SHA_256);

    mutex_unlock(&data_lock);
    
    ztimer_sleep(ZTIMER_MSEC, 5000);
  }
  
  return 0;
}

static char coap_data_stack[THREAD_STACKSIZE_DEFAULT];

int main(void)
{
    setup_coap_client();
    puts("gcoap clinet for IOT app");

    thread_create(coap_data_stack, sizeof(coap_data_stack), THREAD_PRIORITY_MAIN - 1,
      0, coap_server_connect, NULL, "coap_client");

    /* start shell */
    puts("All up, running the shell now");
    char line_buf[SHELL_DEFAULT_BUFSIZE];
    shell_run(shell_commands, line_buf, SHELL_DEFAULT_BUFSIZE);

    /* should never be reached */
    return 0;
}
