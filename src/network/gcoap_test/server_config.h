#ifndef COAP_RESOURCES_H
#define COAP_RESOURCES_H

#define MAIN_QUEUE_SIZE (4)

enum resource_path {
    TEMP,
    TIME,
    CORE,
    BOARD,
    HELLO,
    RIOT_V,
    SHA_256,
    NUM_RESOURCES // Always keep this last
};

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

const char* resource_paths[NUM_RESOURCES] = {
    [TEMP] = "/temperature",
    [TIME] = "/time",
    [CORE] = "/.well-known/core",
    [BOARD] = "/riot/board",  // returns the name of the board running the server. It works only with GET requests.
    [HELLO] = "/echo/hello",
    [RIOT_V] = "/riot/ver",
    [SHA_256] = "/sha256",
};

const char* get_resource_path(resource_path path) {
    return resource_paths[path];
}

#endif /* COAP_RESOURCES_H */