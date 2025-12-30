#include <stdint.h>
#include "../../inc/tcb.h"

extern uint32_t _TTBR0_TASK_1, __irq_task1_stack_top__, __svc_task1_stack_top__, __sys_task1_stack_top__, _TTBR0_TASK_2, __irq_task2_stack_top__, __svc_task2_stack_top__, __sys_task2_stack_top__, _TTBR0_TASK_3, __irq_task3_stack_top__, __svc_task3_stack_top__, __sys_task3_stack_top__, _TTBR0_IDLE, __irq_idle_stack_top__, __svc_idle_stack_top__, __sys_idle_stack_top__; 

extern void* idle;
extern void* task1;
extern void* task2;
extern void* task3;

__attribute__((section(".data_global"))) tcb_t tcbs[4];/* = {
    {__irq_task1_stack_top__, __svc_task1_stack_top__, 8, (uint32_t)&task1},
    {__irq_task2_stack_top__, __svc_task2_stack_top__, 12, (uint32_t)&task2},
    {__irq_task3_stack_top__, __svc_task3_stack_top__, 5, (uint32_t)&task3},
    {__irq_stack_top__, __svc_stack_top__, 5, _idle}
};*/

__attribute__((section(".text"))) void __init_tcb(){
    tcbs[0].sp_irq = (uint32_t*)&__irq_task1_stack_top__;
    tcbs[0].sp_svc = (uint32_t*)&__svc_task1_stack_top__;
    tcbs[0].sp_sys = (uint32_t*)&__sys_task1_stack_top__;
    tcbs[0].ticks = 8;
    tcbs[0].ttrb0 = (uint32_t*)&_TTBR0_TASK_1;
    tcbs[0].lr_svc = (uint32_t*)&task1;
    tcbs[0].lr_sys = (uint32_t*)&task1;

    tcbs[1].sp_irq = (uint32_t*)&__irq_task2_stack_top__;
    tcbs[1].sp_svc = (uint32_t*)&__svc_task2_stack_top__;
    tcbs[1].sp_sys = (uint32_t*)&__sys_task2_stack_top__;
    tcbs[1].ticks = 12;
    tcbs[1].ttrb0 = (uint32_t*)&_TTBR0_TASK_2;
    tcbs[1].lr_svc = (uint32_t*)&task2;
    tcbs[1].lr_sys = (uint32_t*)&task2;

    tcbs[2].sp_irq = (uint32_t*)&__irq_task3_stack_top__;
    tcbs[2].sp_svc = (uint32_t*)&__svc_task3_stack_top__;
    tcbs[2].sp_sys = (uint32_t*)&__sys_task3_stack_top__;
    tcbs[2].ticks = 5;
    tcbs[2].ttrb0 = (uint32_t*)&_TTBR0_TASK_3;
    tcbs[2].lr_svc = (uint32_t*)&task3;
    tcbs[2].lr_sys = (uint32_t*)&task3;

    tcbs[3].sp_irq = (uint32_t*)&__irq_idle_stack_top__;
    tcbs[3].sp_svc = (uint32_t*)&__svc_idle_stack_top__;
    tcbs[3].sp_sys = (uint32_t*)&__sys_idle_stack_top__;
    tcbs[3].ticks = 5;
    tcbs[3].ttrb0 = (uint32_t*)&_TTBR0_IDLE;
    tcbs[3].lr_svc = (uint32_t*)&idle; //idle task, not _idle startup
    tcbs[3].lr_sys = (uint32_t*)&idle; //idle task, not _idle startup

    //inicializar TCBs

    uint32_t svc_spsr;
    uint32_t tcbs_size = sizeof(tcbs) / sizeof(tcbs[0]);

    asm("MRS %0, cpsr" : "=r"(svc_spsr)); // guardar spsr (SVC)
    uint32_t modified_svc_spsr = svc_spsr & ~(0x80); // Habilitar Interrupts IRQ en el svc guardado
    uint32_t modified_usr_spsr = modified_svc_spsr & ~(0xF); // Esto setea el usuario a 0x10 (modo usr)
    
    asm("MSR cpsr_c, #0x80");  //cambiar a modo IRQ

    for(int i = 0; i < tcbs_size; i++){
        tcbs[i].sp_irq = tcbs[i].sp_irq - 1;
        (*tcbs[i].sp_irq) = (uint32_t)tcbs[i].lr_svc;
        tcbs[i].sp_irq = tcbs[i].sp_irq - 14;
        if(i == 3)  (*tcbs[i].sp_irq) = modified_svc_spsr;
        else (*tcbs[i].sp_irq) = modified_usr_spsr;

        //inicializar stacks IRQs como si hubiesen guardado los LR y spsr, con interrupts IRQ enabled
    }

    asm("MSR cpsr_c, %0" : "=r"(svc_spsr)); //Volver al spsr original
}
