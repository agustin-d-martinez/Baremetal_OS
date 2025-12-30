#include <stdint.h>
#include "../../inc/gic.h"
#include "../../inc/timer.h"
#include "../../inc/tcb.h"

extern uint32_t __stack_start__,_PUBLIC_RAM_INIT;

__attribute__((section(".data_global"))) uint32_t* next_available_page;

__attribute__((section(".text"))) void __init_next_available_page(uint32_t* TTBR0){
    next_available_page = TTBR0+0x1000;
}

__attribute__((section(".text"))) uint32_t __page(uint32_t* dir_fis,uint32_t* dir_vir,uint32_t* TTBR0, uint32_t flags ){
    uint32_t level_1 = ((uint32_t)dir_vir >> 20) & 0xFFF;
    uint32_t level_2 = ((uint32_t)dir_vir >> 12) & 0xFF;
    uint32_t* entry_level_1 = TTBR0 + level_1;
    //uint32_t offset = (dir_vir) & 0xFFF;
    uint32_t flags_level_1 = (flags >> 12) & 0xFFF;
    uint32_t flags_level_2 = flags & 0xFFF;  
    
    if ((*entry_level_1) == 0){
        (*entry_level_1) = ((uint32_t)next_available_page | flags_level_1); //TODO: usar los flags, remplazando 0x1 por flags
        next_available_page += 0x400;
    }

    uint32_t** entry_level_2 = (uint32_t**)((*entry_level_1) & ~0xFFF) + level_2;

    if((*entry_level_2) != 0){
        return -1;
    }

    (*entry_level_2) = (uint32_t*)(((uint32_t)dir_fis & ~0xFFF) | flags_level_2); //TODO: usar los flags, remplazando 0x32 por flags
    return 0;
}

__attribute__((section(".text"))) uint32_t __free_page(uint32_t* dir_vir,uint32_t* TTBR0){
    uint32_t level_1 = ((uint32_t)dir_vir >> 20) & 0xFFF;
    uint32_t level_2 = ((uint32_t)dir_vir >> 12) & 0xFF;
    uint32_t* entry_level_1 = TTBR0 + level_1;

    if ((*entry_level_1) == 0){
        return -1;
    }

    uint32_t** entry_level_2 = (uint32_t**)((*entry_level_1) & ~0xFFF) + level_2;

    (*entry_level_2) = (uint32_t*)0x00000000;
    (*entry_level_1) = 0x00000000;

    return 0;
}

extern tcb_t tcbs[4];

__attribute__((section(".text"))) uint32_t __init_paging(uint32_t* TTBR0){
    __init_next_available_page(TTBR0);
    __page((uint32_t*)0x00000000,(uint32_t*)0x00000000,TTBR0,0x001012); //paginar interrupt vector, flag level 1 0x001 flag level 2 0x012 (0x10 significa acceso solo modo privilegiado, 0x02 significa small page)
    __page((uint32_t*)GICC0_ADDR,(uint32_t*)GICC0_ADDR,TTBR0,0x001012); //paginar gic flag level 1 0x001 flag level 2 0x012
    __page((uint32_t*)GICD0_ADDR,(uint32_t*)GICD0_ADDR,TTBR0,0x001012); //paginar gic flag level 1 0x001 flag level 2 0x012
    __page((uint32_t*)TIMER0_ADDR,(uint32_t*)TIMER0_ADDR,TTBR0,0x001012); //paginar gic flag level 1 0x001 flag level 2 0x012
    __page(&_PUBLIC_RAM_INIT,&_PUBLIC_RAM_INIT,TTBR0,0x001012); //paginar codigo kernel flag level 1 0x001 flag level 2 0x012
    __page(&_PUBLIC_RAM_INIT+0x400,&_PUBLIC_RAM_INIT+0x400,TTBR0,0x001012); //paginar codigo kernel flag level 1 0x001 flag level 2 0x012
    __page(&__stack_start__,&__stack_start__,TTBR0,0x001012); //paginar stack kernel flag level 1 0x001 flag level 2 0x012
    __page((&__stack_start__)+0x400,(&__stack_start__)+0x400,TTBR0,0x001012); //paginar stack kernel flag level 1 0x001 flag level 2 0x012

    return 0;
}

extern uint32_t _IDLE_TXT_PHY,_IDLE_TXT_VMA,__svc_idle_stack_top__;

__attribute__((section(".text"))) uint32_t __paging_idle(uint32_t* TTBR0){
    __page(&_IDLE_TXT_PHY,&_IDLE_TXT_VMA,TTBR0,0x001012); //paginar codigo idle (0x10 significa acceso solo modo privilegiado, 0x02 significa small page)
    __page(&__svc_idle_stack_top__, &__svc_idle_stack_top__, TTBR0, 0x001012); //paginar stack idle

    return 0;
}

extern uint32_t _USER_DATA_GLOBAL_PHY,_USER_DATA_GLOBAL_VMA;
extern uint32_t _TASK_1_TXT_PHY,_TASK_1_TXT_VMA,_TASK_1_READ_AREA_PHY,_TASK_1_READ_AREA_VMA,__svc_task1_stack_top__;

__attribute__((section(".text"))) uint32_t __paging_task_1(uint32_t* TTBR0){
    __page(&_TASK_1_TXT_PHY,&_TASK_1_TXT_VMA,TTBR0,0x001022); //paginar codigo task 1 (0x20 significa acceso readonly modo user, 0x02 significa small page)
    __page(&__svc_task1_stack_top__, &__svc_task1_stack_top__, TTBR0, 0x001032); //paginar stack task 1 (0x30 significa acceso libre, 0x02 significa small page)
    __page(&_USER_DATA_GLOBAL_PHY,&_USER_DATA_GLOBAL_VMA,TTBR0,0x001032); //paginar global data (0x30 significa acceso libre, 0x02 significa small page)
    
    for(int i = 0; i<16; i++){
        __page((&_TASK_1_READ_AREA_PHY)+0x400*i,(&_TASK_1_READ_AREA_VMA)+0x400*i,TTBR0,0x001032);
    }

    return 0;
}

extern uint32_t _TASK_2_TXT_PHY,_TASK_2_TXT_VMA,__svc_task2_stack_top__;

__attribute__((section(".text"))) uint32_t __paging_task_2(uint32_t* TTBR0){
    __page(&_TASK_2_TXT_PHY,&_TASK_2_TXT_VMA,TTBR0,0x001022); //paginar codigo task 2 (0x20 significa acceso readonly modo user, 0x02 significa small page)
    __page(&__svc_task2_stack_top__, &__svc_task2_stack_top__, TTBR0, 0x001032); //paginar stack task 2 (0x30 significa acceso libre, 0x02 significa small page)
    __page(&_USER_DATA_GLOBAL_PHY,&_USER_DATA_GLOBAL_VMA,TTBR0,0x001032); //paginar global data

    return 0;
}

extern uint32_t _TASK_3_TXT_PHY,_TASK_3_TXT_VMA,__svc_task3_stack_top__;

__attribute__((section(".text"))) uint32_t __paging_task_3(uint32_t* TTBR0){
    __page(&_TASK_3_TXT_PHY,&_TASK_3_TXT_VMA,TTBR0,0x001022); //paginar codigo task 3 (0x20 significa acceso readonly modo user, 0x02 significa small page)
    __page(&__svc_task3_stack_top__, &__svc_task3_stack_top__, TTBR0, 0x001032); //paginar stack task 3 (0x30 significa acceso libre, 0x02 significa small page)
    __page(&_USER_DATA_GLOBAL_PHY,&_USER_DATA_GLOBAL_VMA,TTBR0,0x001032); //paginar global data 
    
    return 0;
}

__attribute__((section(".text"))) uint32_t __page_all(){
    __init_paging(tcbs[0].ttrb0);
    __paging_task_1(tcbs[0].ttrb0); //paging task 1

    __init_paging(tcbs[1].ttrb0);
    __paging_task_2(tcbs[1].ttrb0); //paging task 2

    __init_paging(tcbs[2].ttrb0);
    __paging_task_3(tcbs[2].ttrb0); //paging task 3

    __init_paging(tcbs[3].ttrb0);
    __paging_idle(tcbs[3].ttrb0); //paging idle

    return 0;
}