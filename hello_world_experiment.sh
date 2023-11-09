#!/usr/bin/env bash
#

if [ -n "$IOT_LAB_FRONTEND_FQDN" ]; then
    source /opt/riot.source
else
    echo "[ERROR] The environment variable IOT_LAB_FRONTEND_FQDN is not set."
fi

#ARCH=nrf52840dk # not available widely in the test bed
ARCH=iotlab-m3

# sensor nodes 20,21,22, 359, 361, 362

make BOARD=${ARCH} -C tutorials_riotos/hello-world
echo tutorials_riotos/hello-world/bin/${ARCH}/hello-world.elf
cp tutorials_riotos/hello-world/bin/${ARCH}/hello-world.elf ~/shared/

## submitting a job in iot test bed with the firmware it self
iotlab-experiment submit -n hello_gp_12 -d 3 -l grenoble,m3,359-361,~/shared/hello-world.elf

