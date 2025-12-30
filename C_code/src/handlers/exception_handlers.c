#include <stddef.h>
#include <stdint.h>
#include "../../inc/gic.h"
#include "../../inc/timer.h"
#include "../../inc/ctx_t.h"

extern ctx_t* scheduler( ctx_t*ctx );

__attribute__((section(".text"))) ctx_t* kernel_handler_irq( ctx_t*ctx ){
 // Paso 2: leemos el registro IAR para identificar que interrupcion se ha generado
    _gicc_t* const GICC0 = (_gicc_t*) GICC0_ADDR;
    _timer_t* const TIMER0 = (_timer_t*) TIMER0_ADDR;
    uint32_t id = GICC0->IAR; // usa -> porque GICC0 es un puntero _gicc_t, no un objeto _gicc_t (si fuese objeto usaria .)
                                //Interrupt Acknoledge Register 

    //manejamos la interrupcion, luego limpiamos o reseteamos la fuente
    switch(id){
        case GIC_SOURCE_TIMER0 : { 
        TIMER0->Timer1IntClr = 0x01; //Limpiar Flag
        ctx = scheduler(ctx); //llamar scheduler
        break;
        }
        default: {
        break;
        }
    }
    //le avisamos al controlador que ya esta
    GICC0->EOIR = id;

    return ctx;
}

__attribute__((section(".data_global"))) uint32_t kernel_variable=0;

__attribute__((section(".text"))) uint32_t read_kernel_variable(){
    return kernel_variable;
}

__attribute__((section(".text"))) void write_kernel_variable(uint32_t value){
    kernel_variable=value;
}

__attribute__((section(".text"))) uint32_t kernel_handler_svc( uint32_t svc_number, uint32_t arg1, uint32_t arg2, uint32_t arg3){
    switch(svc_number){
        case 0 : {
            return read_kernel_variable();
        }
        case 1 : {
            write_kernel_variable(arg1);
            break;
        }
        default: {
            break;
        }
    }
    return 0;
}