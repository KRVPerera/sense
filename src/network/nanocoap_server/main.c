/*
 * Copyright (C) 2016 Kaspar Schleiser <kaspar@schleiser.de>
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
 * @brief       CoAP example server application (using nanocoap)
 *
 * @author      Kaspar Schleiser <kaspar@schleiser.de>
 * @}
 */

#include <stdio.h>

#include "net/nanocoap_sock.h"
#include "xtimer.h"

#define COAP_INBUF_SIZE (256U)

#define MAIN_QUEUE_SIZE     (8)
static msg_t _main_msg_queue[MAIN_QUEUE_SIZE];

// static ssize_t _temperature_handler(coap_pkt_t* pkt, uint8_t *buf, size_t len, coap_request_ctx_t *context __attribute__((unused)))
// {
//     // Implement your logic for handling GET request
//     puts("GET request received");

//     // You can also read the request data from 'pkt' if needed

//     // Prepare the response
//     const char *response_msg = "This is the response to your GET request";
//     ssize_t reply_len = coap_reply_simple(pkt, COAP_CODE_CONTENT, buf, len, COAP_FORMAT_TEXT, (uint8_t *)response_msg, strlen(response_msg));

//     return reply_len;
// }

// NANOCOAP_RESOURCE(temperature) {
//   .path = "/temperature", .methods = COAP_GET, .handler = _temperature_handler,
//   .path = "/board", .methods = COAP_GET, .handler = _board_handler,
// };

int main(void)
{
    puts("RIOT nanocoap example application");

    /* nanocoap_server uses gnrc sock which uses gnrc which needs a msg queue */
    msg_init_queue(_main_msg_queue, MAIN_QUEUE_SIZE);

    puts("Waiting for address autoconfiguration...");
    xtimer_sleep(3);

    /* print network addresses */
    printf("{\"IPv6 addresses\": [\"");
    netifs_print_ipv6("\", \"");
    puts("\"]}");

    /* initialize nanocoap server instance */
    uint8_t buf[COAP_INBUF_SIZE];
    sock_udp_ep_t local = { .port=COAP_PORT, .family=AF_INET6 };
    nanocoap_server(&local, buf, sizeof(buf));

    /* should be never reached */
    return 0;
}
