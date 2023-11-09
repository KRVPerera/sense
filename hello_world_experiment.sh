#!/usr/bin/env bash
#

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
    source /opt/riot.source
else
    echo "[ERROR] The environment variable IOT_LAB_FRONTEND_FQDN is not set."
fi

ARCH=nrf52840dk

make BOARD=${ARCH} -C tutorials_riotos/hello-world
echo tutorials_riotos/hello-world/bin/${ARCH}/hello-world.elf
cp tutorials_riotos/hello-world/bin/${ARCH}/hello-world.elf ~/shared/

