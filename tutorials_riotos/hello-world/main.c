#include <stdio.h>
#include "ztimer.h"

int main(void)
{
    int sequence = 0;
    while (1)
    {
        puts("");
        puts("#-------------------------------------------------------#");
        printf("#----- This is group 12 talking Hello world - (%4d)  --#\n", sequence);
        puts("#-------------------------------------------------------#\n");

        printf("You are running RIOT on a(n) %s board.\n", RIOT_BOARD);
        printf("This board features a(n) %s MCU.\n", RIOT_MCU);
        sequence += 1;
        if (sequence > 1000) {
            sequence = 0;
        }
        ztimer_sleep(ZTIMER_MSEC, 1000);
    }

    return 0;
}
