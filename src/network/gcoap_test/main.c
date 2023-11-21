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

#include "gcoap_example.h"

#define MAIN_QUEUE_SIZE (4)
static msg_t _main_msg_queue[MAIN_QUEUE_SIZE];

static const shell_command_t shell_commands[] = {
    {"coap", "CoAP example", gcoap_cli_cmd},
    {NULL, NULL, NULL}};

/* Buffer for the request */
static uint8_t _req_buf[CONFIG_GCOAP_PDU_BUF_SIZE];

/* Response handler */
static void _resp_handler(const gcoap_request_memo_t *memo, coap_pkt_t *pdu, const sock_udp_ep_t *remote)
{
    (void)remote; // Unused parameter

    if (memo->state == GCOAP_MEMO_RESP)
    {
        char *data = (char *)pdu->payload;
        size_t data_len = pdu->payload_len;
        printf("Response: %.*s\n", data_len, data);
    }
    else
    {
        printf("Request timed out\n");
    }
}

void send_coap_get_request(void)
{
    sock_udp_ep_t remote;
    ipv6_addr_t addr;

    /* Parse the destination address */
    ipv6_addr_from_str(&addr, "2001:660:5307:3107:a4a9:dc28:5c45:38a9");
    remote.family = AF_INET6;
    remote.port = 5683;
    memcpy(&remote.addr.ipv6[0], &addr.u8[0], sizeof(addr.u8));

    /* Prepare the CoAP request */
    coap_pkt_t pdu;
    gcoap_req_init(&pdu, _req_buf, CONFIG_GCOAP_PDU_BUF_SIZE, COAP_METHOD_GET, "/.well-known/core");
    size_t len = coap_opt_finish(&pdu, 0);

    /* Send the request */
    gcoap_req_send(_req_buf, len, &remote, _resp_handler, NULL);
}

int gcoap_cli_cmd_2(void)
{
    uint8_t buf[CONFIG_GCOAP_PDU_BUF_SIZE];
    coap_pkt_t pdu;
    ssize_t pdu_len;

    // Define the remote endpoint
    sock_udp_ep_t remote = {
        .family = AF_INET6,
        .port = 5683
    };

    // Convert string to IPv6 address
    ipv6_addr_t addr;
    if (!ipv6_addr_from_str(&addr, "2001:660:5307:3107:a4a9:dc28:5c45:38a9")) {
        printf("Error: Invalid IPv6 address\n");
        return -1;
    }
    memcpy(remote.addr.ipv6, &addr, sizeof(addr));
    printf("IPv6 Address set for CoAP request\n");

    // Initialize the CoAP request
    gcoap_req_init(&pdu, buf, CONFIG_GCOAP_PDU_BUF_SIZE, COAP_METHOD_GET, "/.well-known/core");
    printf("CoAP request initialized\n");

    // Complete the CoAP PDU and get the length
    pdu_len = coap_opt_finish(&pdu, COAP_OPT_FINISH_NONE);

    if (pdu_len <= 0) {
        printf("Error: PDU preparation failed\n");
        return -1;
    }
    printf("PDU prepared, length: %zd\n", pdu_len);

    // Send the CoAP GET request
    if (gcoap_req_send(buf, pdu_len, &remote, _resp_handler, NULL) <= 0) {
        printf("Error: Sending CoAP request failed\n");
        return -1;
    }
    printf("CoAP request sent successfully\n");

    return 0;
}

int main(void)
{
    /* for the thread running the shell */
    msg_init_queue(_main_msg_queue, MAIN_QUEUE_SIZE);
    puts("gcoap example app");

    while(1) {
        send_coap_get_request();

        ztimer_sleep(ZTIMER_MSEC, 2000);
        gcoap_cli_cmd_2();

        ztimer_sleep(ZTIMER_MSEC, 2000);
    }

    /* start shell */
    puts("All up, running the shell now");
    char line_buf[SHELL_DEFAULT_BUFSIZE];
    shell_run(shell_commands, line_buf, SHELL_DEFAULT_BUFSIZE);

    /* should never be reached */
    return 0;
}
