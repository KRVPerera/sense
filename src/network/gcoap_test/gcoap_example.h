/*
 * Copyright (C) 2020 Otto-von-Guericke-Universität Magdeburg
 *
 * This file is subject to the terms and conditions of the GNU Lesser General
 * Public License v2.1. See the file LICENSE in the top level directory for more
 * details.
 */

/**
 * @ingroup     examples
 * @{
 *
 * @file
 * @brief       gcoap example
 *
 * @author      Ken Bannister <kb2ma@runbox.com>
 */

#ifndef GCOAP_EXAMPLE_H
#define GCOAP_EXAMPLE_H

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "fmt.h"
#include "net/gcoap.h"
#include "net/utils.h"
#include "od.h"

#ifdef __cplusplus
extern "C" {
#endif


typedef enum resource_path {
    TEMP,
    TIME,
    CORE,
    BOARD,
    HELLO,
    RIOT_V,
    SHA_256,
    NUM_RESOURCES // Always keep this last
} resource_path;

/* server setup in rios os gcoap_server
/.well-known/core: returns the list of available resources on the server. This is part of the CoAP specifications. 
                    It works only with GET requests.
/echo/: will match any request that begins with '/echo/' and will echo the remaining part of the URI path. 
            Meant to show how the prefix works. It works only with GET requests.
/riot/board: returns the name of the board running the server. It works only with GET requests.
/riot/value: returns the value of an internal variable of the server. It works with GET requests 
            and also with PUT and POST requests, which means that this value can be updated from a client.
/riot/ver: returns the current RIOT version. Meant to show a block2 reply. It works only with GET requests.
/sha256: creates a hash with the received payloads. It is meant to show block1 support. 
        It returns the hash when no more blocks are pending. Only works with POST.

*/


const char* get_resource_path(resource_path path);
int get_resource_path_len(resource_path path);

extern uint16_t req_count;  /**< Counts requests sent by CLI. */

/**
 * @brief   Shell interface exposing the client side features of gcoap
 * @param   argc    Number of shell arguments (including shell command name)
 * @param   argv    Shell argument values (including shell command name)
 * @return  Exit status of the shell command
 */
int gcoap_cli_cmd(int argc, char **argv);

void send_coap_get_request(resource_path path);
int gcoap_post(char* msg, resource_path path);

/**
 * @brief   Registers the CoAP resources exposed in the example app
 *
 * Run this exactly one during startup.
 */
void server_init(void);

/**
 * @brief   Notifies all observers registered to /cli/stats - if any
 *
 * Call this whenever the count of successfully send client requests changes
 */
void notify_observers(void);

#ifdef __cplusplus
}
#endif

#endif /* GCOAP_EXAMPLE_H */
/** @} */
