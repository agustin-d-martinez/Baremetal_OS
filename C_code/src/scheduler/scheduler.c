#include <stdint.h>
#include <stdbool.h>
#include "../../inc/ctx_t.h"
#include "../../inc/tcb.h"

__attribute__((section(".data_global"))) uint32_t ticks = 0;
__attribute__((section(".data_global"))) bool first_ctx_switch = true;
__attribute__((section(".data_global"))) uint32_t current_task = 3; //Empieza en Task Idle

extern tcb_t tcbs[4];

__attribute__((section(".text"))) ctx_t* scheduler( ctx_t*ctx ){
    ctx_t* sp_irq = ctx;
    ticks++;

    if(ticks > tcbs[current_task].ticks)
    {
        uint32_t next_task = (current_task + 1) % 4;
        ticks = 0;        

        if(!first_ctx_switch) tcbs[current_task].sp_irq = (uint32_t*)sp_irq; //store current sp_irq

        asm volatile("CPS 0x13"); //Change mode to SVC

        if(!first_ctx_switch){
            asm volatile("MOV %0, sp" : "=r"(tcbs[current_task].sp_svc)); //store current task stack pointer svc mode
            asm volatile("MOV %0, lr" : "=r"(tcbs[current_task].lr_svc)); //store current link register svc mode
        }
        asm volatile("MOV sp, %0" :: "r"(tcbs[next_task].sp_svc)); //load next task stack pointer svc mode
        asm volatile("MOV lr, %0" :: "r"(tcbs[next_task].lr_svc)); //load next link register pointer svc mode

        asm volatile("CPS 0x1F"); //Change mode to SYS (privileged USR)

        if(!first_ctx_switch){
            asm volatile("MOV %0, sp" : "=r"(tcbs[current_task].sp_sys)); //store current task stack pointer user mode
            asm volatile("MOV %0, lr" : "=r"(tcbs[current_task].lr_sys)); //store current link register user mode
        }
        asm volatile("MOV sp, %0" :: "r"(tcbs[next_task].sp_sys)); //load next task stack pointer user mode
        asm volatile("MOV lr, %0" :: "r"(tcbs[next_task].lr_sys)); //load next link register pointer user mode
        
        asm volatile("CPS 0x12"); //Change mode to IRQ
        
        
        sp_irq = (ctx_t*)tcbs[next_task].sp_irq; //load next task sp_irq
        asm volatile("MOV R10, %0" :: "r"(tcbs[next_task].ttrb0));
        asm volatile("MCR p15, 0, R10, c2, c0, 0"); //load next task ttrb0
        first_ctx_switch = false;

        current_task = next_task; 
    }

    return sp_irq;
}