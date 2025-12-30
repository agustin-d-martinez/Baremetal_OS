
#include "../../inc/timer.h"

__attribute__((section(".text"))) void __timer_init()
    {
        _timer_t* const TIMER0 = ( _timer_t* )TIMER0_ADDR; // puntero a el registro de TIMER0

        TIMER0->Timer1Load     = 0x00010000;    //contains the value from which the counter is to decrement. (65536)
        TIMER0->Timer1Ctrl     = 0x00000002;    //bit [1] selects counter size (0 = 16-bit counter, 1=32-bit counter)
        TIMER0->Timer1Ctrl    |= 0x00000040;    //Timer mode (1 = periodic mode)
        TIMER0->Timer1Ctrl    |= 0x00000020;    //Interrupt enable bit (1 = enable)
        TIMER0->Timer1Ctrl    |= 0x00000080;    //Timer enable bit (1 = enable)

    }