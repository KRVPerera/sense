#!/usr/bin/env bash
#

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
    source /opt/riot.source
else
    echo "The environment variable IOT_LAB_FRONTEND_FQDN is not set."
fi

make IOTLAB_NODE=auto flash term
