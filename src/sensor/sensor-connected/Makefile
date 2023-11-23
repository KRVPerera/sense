APPLICATION = sensor-connected_gp12

BOARD ?= iotlab-m3

USEMODULE += ztimer_usec
USEMODULE += ztimer_msec
USEMODULE += ztimer_sec
USEMODULE += ztimer_no_periph_rtt
USEMODULE += lps331ap
USEMODULE += xtimer

DEVELHELP ?= 0

# CFLAGS += -Werror -Wall -Wextra -Wshadow -Wdouble-promotion -Wformat=2 -Wformat-security -Wundef -fno-common

CFLAGS += -Werror -Wall -Wextra -Wshadow -Wdouble-promotion -Wformat=2 -Wformat-security -fno-common

RIOTBASE ?= ../../../external/RIOT

include $(RIOTBASE)/Makefile.include
