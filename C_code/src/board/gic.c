
#include "../../inc/gic.h"

__attribute__((section(".text"))) void __gic_init()
    {
        _gicc_t* const GICC0 = (_gicc_t*)GICC0_ADDR;
        _gicd_t* const GICD0 = (_gicd_t*)GICD0_ADDR;

        GICC0->PMR  = 0x000000F0;           //[7:4]=0xF interrumpir con prioridad. [3:0]= ceros (es mascara)
        GICD0->ISENABLER[1] |= 0x00000010;  //Set-enable1. bit set to 1 indicates an enabled interrupt
        GICD0->ISENABLER[1] |= 0x00001000;  //ditto
        GICC0->CTLR         = 0x00000001;   //enable the CPU interface for this GIC.
        GICD0->CTLR         = 0x00000001;   //enable the CPU interface for this GIC (distributor).

    }