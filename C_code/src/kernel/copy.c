#include <stdint.h>

__attribute__((section(".text"))) void __copy(uint32_t* src, uint32_t* dst, int32_t size){
    for(int i = size/4; i > 0; i--){
        *(dst)++=*(src)++;
    }
}

__attribute__((section(".text"))) void __move(uint32_t* src, uint32_t* dst, int32_t size){
    for(int i = size/4; i > 0; i--){
        *(dst)++=*(src);
        *(src)++=0;
    }
}

extern uint32_t _IDLE_TXT_LMA,_IDLE_TXT_PHY,__idle_size__;
extern uint32_t _TASK_1_TXT_LMA,_TASK_1_TXT_PHY,__task1_size__;
extern uint32_t _TASK_2_TXT_LMA,_TASK_2_TXT_PHY,__task2_size__;
extern uint32_t _TASK_3_TXT_LMA,_TASK_3_TXT_PHY,__task3_size__;

__attribute__((section(".text"))) void __move_lma_to_phy(){
    __move(&_IDLE_TXT_LMA,&_IDLE_TXT_PHY,(int32_t)&__idle_size__);
    __move(&_TASK_1_TXT_LMA,&_TASK_1_TXT_PHY,(int32_t)&__task1_size__);
    __move(&_TASK_2_TXT_LMA,&_TASK_2_TXT_PHY,(int32_t)&__task2_size__);
    __move(&_TASK_3_TXT_LMA,&_TASK_3_TXT_PHY,(int32_t)&__task3_size__);
}