/*
 * Copyright (c) 2015-2017 Ken Bannister. All rights reserved.
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
 * @brief       gcoap CLI support
 *
 * @author      Ken Bannister <kb2ma@runbox.com>
 * @author      Hauke Petersen <hauke.petersen@fu-berlin.de>
 * @author      Hendrik van Essen <hendrik.ve@fu-berlin.de>
 *
 * @}
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <arpa/inet.h>

#include "fmt.h"
#include "net/gcoap.h"
#include "net/sock/util.h"
#include "net/utils.h"
#include "od.h"

#include "gcoap_example.h"

#define ENABLE_DEBUG 1
#include "debug.h"

#if IS_USED(MODULE_GCOAP_DTLS)
#include "net/dsm.h"
#endif

static bool _proxied = false;
static sock_udp_ep_t _proxy_remote;
static char proxy_uri[64];

/* Retain request path to re-request if response includes block. User must not
 * start a new request (with a new path) until any blockwise transfer
 * completes or times out. */
#define _LAST_REQ_PATH_MAX (64)
static char *server_ip = GCOAP_AMAZON_SERVER_IP_ONLY;
static char _last_req_path[_LAST_REQ_PATH_MAX];

uint16_t req_count = 0;

/* Buffer for the request */
// static uint8_t _req_buf[CONFIG_GCOAP_PDU_BUF_SIZE];

const char* resource_paths[NUM_RESOURCES] = {
    [TEMP] = "/temp",
    [TIME] = "/time",
    [CORE] = "/.well-known/core",
    [BOARD] = "/riot/board",  // returns the name of the board running the server. It works only with GET requests.
    [HELLO] = "/echo/hello",
    [RIOT_V] = "/riot/ver",
    [SHA_256] = "/sha256",
};

int resource_paths_len[NUM_RESOURCES] = {
    [TEMP] = 13,
    [TIME] = 6,
    [CORE] = 18,
    [BOARD] = 12,  // returns the name of the board running the server. It works only with GET requests.
    [HELLO] = 12,
    [RIOT_V] = 10,
    [SHA_256] = 8,
};

const char* get_resource_path(resource_path path) {
    return resource_paths[path];
}

int get_resource_path_len(resource_path path) {
    return resource_paths_len[path];
}

/*
 * Response callback.
 */
static void _resp_handler(const gcoap_request_memo_t *memo, coap_pkt_t* pdu,
                          const sock_udp_ep_t *remote)
{
    (void)remote;       /* not interested in the source currently */

    if (memo->state == GCOAP_MEMO_TIMEOUT) {
        printf("gcoap: timeout for msg ID %02u\n", coap_get_id(pdu));
        return;
    }
    else if (memo->state == GCOAP_MEMO_RESP_TRUNC) {
        /* The right thing to do here would be to look into whether at least
         * the options are complete, then to mentally trim the payload to the
         * next block boundary and pretend it was sent as a Block2 of that
         * size. */
        printf("gcoap: warning, incomplete response; continuing with the truncated payload\n");
    }
    else if (memo->state != GCOAP_MEMO_RESP) {
        printf("gcoap: error in response\n");
        return;
    }

    coap_block1_t block;
    if (coap_get_block2(pdu, &block) && block.blknum == 0) {
        puts("--- blockwise start ---");
    }

    char *class_str = (coap_get_code_class(pdu) == COAP_CLASS_SUCCESS)
                            ? "Success" : "Error";
    printf("gcoap: response %s, code %1u.%02u", class_str,
                                                coap_get_code_class(pdu),
                                                coap_get_code_detail(pdu));
    if (pdu->payload_len) {
        unsigned content_type = coap_get_content_type(pdu);
        if (content_type == COAP_FORMAT_TEXT
                || content_type == COAP_FORMAT_LINK
                || coap_get_code_class(pdu) == COAP_CLASS_CLIENT_FAILURE
                || coap_get_code_class(pdu) == COAP_CLASS_SERVER_FAILURE) {
            /* Expecting diagnostic payload in failure cases */
            printf(", %u bytes\n%.*s\n", pdu->payload_len, pdu->payload_len,
                                                          (char *)pdu->payload);
        }
        else {
            printf(", %u bytes\n", pdu->payload_len);
            od_hex_dump(pdu->payload, pdu->payload_len, OD_WIDTH_DEFAULT);
        }
    }
    else {
        printf(", empty payload\n");
    }

    /* ask for next block if present */
    if (coap_get_block2(pdu, &block)) {
        if (block.more) {
            unsigned msg_type = coap_get_type(pdu);
            if (block.blknum == 0 && !strlen(_last_req_path)) {
                puts("Path too long; can't complete blockwise");
                return;
            }

            if (_proxied) {
                gcoap_req_init(pdu, (uint8_t *)pdu->hdr, CONFIG_GCOAP_PDU_BUF_SIZE,
                               COAP_METHOD_GET, NULL);
            }
            else {
                gcoap_req_init(pdu, (uint8_t *)pdu->hdr, CONFIG_GCOAP_PDU_BUF_SIZE,
                               COAP_METHOD_GET, _last_req_path);
            }

            if (msg_type == COAP_TYPE_ACK) {
                coap_hdr_set_type(pdu->hdr, COAP_TYPE_CON);
            }
            block.blknum++;
            coap_opt_add_block2_control(pdu, &block);

            if (_proxied) {
                coap_opt_add_proxy_uri(pdu, _last_req_path);
            }

            int len = coap_opt_finish(pdu, COAP_OPT_FINISH_NONE);
            gcoap_req_send((uint8_t *)pdu->hdr, len, remote,
                           _resp_handler, memo->context);
        }
        else {
            puts("--- blockwise complete ---");
        }
    }
}

static size_t _send(uint8_t *buf, size_t len, char *addr_str)
{
    size_t bytes_sent;
    sock_udp_ep_t *remote;
    sock_udp_ep_t new_remote;

    if (_proxied) {
        remote = &_proxy_remote;
    }
    else {
        if (sock_udp_name2ep(&new_remote, addr_str) != 0) {
            return 0;
        }

        if (new_remote.port == 0) {
            if (IS_USED(MODULE_GCOAP_DTLS)) {
                new_remote.port = CONFIG_GCOAPS_PORT;
            }
            else {
                new_remote.port = CONFIG_GCOAP_PORT;
            }
        }

        remote = &new_remote;
    }

    bytes_sent = gcoap_req_send(buf, len, remote, _resp_handler, NULL);
    if (bytes_sent > 0) {
        req_count++;
    }
    return bytes_sent;
}

static int _print_usage(char **argv)
{
    printf("usage: %s <get|post|put|ping|proxy|info>\n", argv[0]);
    return 1;
}

void send_coap_get_request(resource_path path)
{
    printf("\n------ (START) coap get-------\n");
    ipv6_addr_t addr;
    sock_udp_ep_t remote;
    remote.family = AF_INET6;
    remote.port = 5683;

    int uri_len = get_resource_path_len(path);
    const char *uri = get_resource_path(path);

    
    /* Parse the destination address */
    if (!ipv6_addr_from_str(&addr, server_ip)) {
        printf("Error: Invalid IPv6 address : %s\n", server_ip);
        return;
    }
    
    memcpy(&remote.addr.ipv6[0], &addr.u8[0], sizeof(addr.u8));
    printf("IPv6 Address set for CoAP request\n");

    /* Prepare the CoAP request */
    uint8_t buf[CONFIG_GCOAP_PDU_BUF_SIZE];
    coap_pkt_t pdu;
    gcoap_req_init(&pdu, &buf[0], CONFIG_GCOAP_PDU_BUF_SIZE, COAP_METHOD_GET, uri);
    coap_hdr_set_type(pdu.hdr, COAP_TYPE_CON);
    coap_opt_add_format(&pdu, COAP_FORMAT_TEXT);

    memset(_last_req_path, 0, _LAST_REQ_PATH_MAX);
    if (uri_len < _LAST_REQ_PATH_MAX) {
        memcpy(_last_req_path, uri, uri_len);
    }

    size_t len = coap_opt_finish(&pdu, COAP_OPT_FINISH_NONE);

    printf("gcoap_get: sending msg ID %u, %u bytes\n", coap_get_id(&pdu),
               (unsigned) len);

    if (!_send(&buf[0], len, GCOAP_AMAZON_SERVER_IP)) {
        puts("gcoap_cli: msg send failed");
    }

    printf("\n------ (END) coap get-------\n");
}

int gcoap_post(char* msg, resource_path path)
{
    printf("\n------ (START) coap post-------\n");
    uint8_t buf[CONFIG_GCOAP_PDU_BUF_SIZE];
    coap_pkt_t pdu;
    ssize_t pdu_len;
    size_t len;

    // Define the remote endpoint
    sock_udp_ep_t remote = {
        .family = AF_INET6,
        .port = 5683
    };

    int uri_len = get_resource_path_len(path);
    const char *uri = get_resource_path(path);

    // Convert string to IPv6 address
    ipv6_addr_t addr;
    if (!ipv6_addr_from_str(&addr, server_ip)) {
        printf("Error: Invalid IPv6 address\n");
        return -1;
    }
    memcpy(remote.addr.ipv6, &addr, sizeof(addr));
    DEBUG_PRINT("IPv6 Address set for CoAP request\n");

    // Initialize the CoAP request
    gcoap_req_init(&pdu, buf, CONFIG_GCOAP_PDU_BUF_SIZE, COAP_METHOD_POST, uri);
    DEBUG_PRINT("CoAP request initialized\n");
    coap_hdr_set_type(pdu.hdr, COAP_TYPE_CON);

    memset(_last_req_path, 0, _LAST_REQ_PATH_MAX);
    if (uri_len < _LAST_REQ_PATH_MAX) {
       memcpy(_last_req_path, uri, uri_len);
    }

    // format message
    coap_opt_add_format(&pdu, COAP_FORMAT_TEXT);
    pdu_len = coap_opt_finish(&pdu, COAP_OPT_FINISH_PAYLOAD);
    len = pdu_len;
    size_t paylen = strlen(msg);

    if (pdu.payload_len >= paylen) {
        memcpy(pdu.payload, msg, paylen);
        len += paylen;
    }
    else {
        puts("gcoap_cli: msg buffer too small");
        return 1;
    }

    if (pdu_len <= 0) {
        printf("Error: PDU preparation failed\n");
        return -1;
    }
    DEBUG_PRINT("PDU prepared, length: %d\n", pdu_len);
    DEBUG_PRINT("sending msg ID %u, %u bytes\n", coap_get_id(&pdu), (unsigned) len);

    size_t ip_length = strlen(GCOAP_AMAZON_SERVER_IP) + 1;
    char ip_add[ip_length];

    // Constructing the string
    snprintf(ip_add, ip_length, "%s", GCOAP_AMAZON_SERVER_IP);

    if (!_send(&buf[0], len, ip_add)) {
        puts("gcoap_cli: msg send failed");
    }
    DEBUG_PRINT("CoAP request sent successfully\n");

    printf("\n------ (END) coap post-------\n");
    return 0;
}

int gcoap_cli_cmd(int argc, char **argv)
{
    /* Ordered like the RFC method code numbers, but off by 1. GET is code 0. */
    char *method_codes[] = {"ping", "get", "post", "put"};
    uint8_t buf[CONFIG_GCOAP_PDU_BUF_SIZE];
    coap_pkt_t pdu;
    size_t len;

    if (argc == 1) {
        /* show help for main commands */
        return _print_usage(argv);
    }

    if (strcmp(argv[1], "info") == 0) {
        uint8_t open_reqs = gcoap_op_state();

        if (IS_USED(MODULE_GCOAP_DTLS)) {
            printf("CoAP server is listening on port %u\n", CONFIG_GCOAPS_PORT);
        } else {
            printf("CoAP server is listening on port %u\n", CONFIG_GCOAP_PORT);
        }
#if IS_USED(MODULE_GCOAP_DTLS)
        printf("Connection secured with DTLS\n");
        printf("Free DTLS session slots: %d/%d\n", dsm_get_num_available_slots(),
                dsm_get_num_maximum_slots());
#endif
        printf(" CLI requests sent: %u\n", req_count);
        printf("CoAP open requests: %u\n", open_reqs);
        printf("Configured Proxy: ");
        if (_proxied) {
#ifdef SOCK_HAS_IPV6
            char addrstr[IPV6_ADDR_MAX_STR_LEN];
#else
            char addrstr[IPV4_ADDR_MAX_STR_LEN];
#endif
            inet_ntop(_proxy_remote.family, &_proxy_remote.addr, addrstr, sizeof(addrstr));

            if (_proxy_remote.family == AF_INET6) {
                printf("[%s]:%u\n", addrstr, _proxy_remote.port);
            }
            else {
                printf("%s:%u\n", addrstr, _proxy_remote.port);
            }
        }
        else {
            puts("None");
        }
        return 0;
    }
    else if (strcmp(argv[1], "proxy") == 0) {
        if ((argc == 4) && (strcmp(argv[2], "set") == 0)) {
            if (sock_udp_name2ep(&_proxy_remote, argv[3]) != 0) {
                puts("Could not set proxy");
                return 1;
            }

            if (_proxy_remote.port == 0) {
                if (IS_USED(MODULE_GCOAP_DTLS)) {
                    _proxy_remote.port = CONFIG_GCOAPS_PORT;
                }
                else {
                    _proxy_remote.port = CONFIG_GCOAP_PORT;
                }
            }

            _proxied = true;
            return 0;
        }
        if ((argc == 3) && (strcmp(argv[2], "unset") == 0)) {
            memset(&_proxy_remote, 0, sizeof(_proxy_remote));
            _proxied = false;
            return 0;
        }
        printf("usage: %s proxy set <host>[:port]\n", argv[0]);
        printf("       %s proxy unset\n", argv[0]);
        return 1;
    }

    /* if not 'info' and 'proxy', must be a method code or ping */
    int code_pos = -1;
    for (size_t i = 0; i < ARRAY_SIZE(method_codes); i++) {
        if (strcmp(argv[1], method_codes[i]) == 0) {
            code_pos = i;
        }
    }
    if (code_pos == -1) {
        return _print_usage(argv);
    }

    /* parse options */
    int apos = 2;       /* position of address argument */
    /* ping must be confirmable */
    unsigned msg_type = (!code_pos ? COAP_TYPE_CON : COAP_TYPE_NON);
    if (argc > apos && strcmp(argv[apos], "-c") == 0) {
        msg_type = COAP_TYPE_CON;
        apos++;
    }

    if (((argc == apos + 1) && (code_pos == 0)) ||    /* ping */
        ((argc == apos + 2) && (code_pos == 1)) ||    /* get */
        ((argc == apos + 2 ||
          argc == apos + 3) && (code_pos > 1))) {     /* post or put */

        char *uri = NULL;
        int uri_len = 0;
        if (code_pos) {
            uri = argv[apos+1];
            uri_len = strlen(argv[apos+1]);
        }

        if (uri && ((uri_len <= 0) || (uri[0] != '/'))) {
            puts("ERROR: URI-Path must start with a \"/\"");
            return _print_usage(argv);
        }

        if (_proxied) {
            sock_udp_ep_t tmp_remote;
            if (sock_udp_name2ep(&tmp_remote, argv[apos]) != 0) {
                return _print_usage(argv);
            }

            if (tmp_remote.port == 0) {
                if (IS_USED(MODULE_GCOAP_DTLS)) {
                    tmp_remote.port = CONFIG_GCOAPS_PORT;
                }
                else {
                    tmp_remote.port = CONFIG_GCOAP_PORT;
                }
            }

#ifdef SOCK_HAS_IPV6
            char addrstr[IPV6_ADDR_MAX_STR_LEN];
#else
            char addrstr[IPV4_ADDR_MAX_STR_LEN];
#endif
            inet_ntop(tmp_remote.family, &tmp_remote.addr, addrstr, sizeof(addrstr));

            if (tmp_remote.family == AF_INET6) {
                uri_len = snprintf(proxy_uri, sizeof(proxy_uri), "coap://[%s]:%d%s",
                                   addrstr, tmp_remote.port, uri);
            }
            else {
                uri_len = snprintf(proxy_uri, sizeof(proxy_uri), "coap://%s:%d%s",
                                   addrstr, tmp_remote.port, uri);
            }

            uri = proxy_uri;

            gcoap_req_init(&pdu, &buf[0], CONFIG_GCOAP_PDU_BUF_SIZE, code_pos, NULL);
        }
        else {
            gcoap_req_init(&pdu, &buf[0], CONFIG_GCOAP_PDU_BUF_SIZE, code_pos, uri);
        }
        coap_hdr_set_type(pdu.hdr, msg_type);

        memset(_last_req_path, 0, _LAST_REQ_PATH_MAX);
        if (uri_len < _LAST_REQ_PATH_MAX) {
            memcpy(_last_req_path, uri, uri_len);
        }

        size_t paylen = (argc == apos + 3) ? strlen(argv[apos+2]) : 0;
        if (paylen) {
            coap_opt_add_format(&pdu, COAP_FORMAT_TEXT);
        }

        if (_proxied) {
            coap_opt_add_proxy_uri(&pdu, uri);
        }

        if (paylen) {
            len = coap_opt_finish(&pdu, COAP_OPT_FINISH_PAYLOAD);
            if (pdu.payload_len >= paylen) {
                memcpy(pdu.payload, argv[apos+2], paylen);
                len += paylen;
            }
            else {
                puts("gcoap_cli: msg buffer too small");
                return 1;
            }
        }
        else {
            len = coap_opt_finish(&pdu, COAP_OPT_FINISH_NONE);
        }

        printf("gcoap_cli: sending msg ID %u, %u bytes\n", coap_get_id(&pdu),
               (unsigned) len);
        if (!_send(&buf[0], len, argv[apos])) {
            puts("gcoap_cli: msg send failed");
        }
        else {
            /* send Observe notification for /cli/stats */
            notify_observers();
        }
        return 0;
    }
    else {
        printf("usage: %s <get|post|put> [-c] <host>[:port] <path> [data]\n",
               argv[0]);
        printf("       %s ping <host>[:port]\n", argv[0]);
        printf("Options\n");
        printf("    -c  Send confirmably (defaults to non-confirmable)\n");
        return 1;
    }

    return _print_usage(argv);
}
