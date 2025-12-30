#include <stdint.h>
#include "../../inc/global_variables.h"

__attribute__((section(".task2"))) void task2(){
    int volatile local = 0;
    uint32_t secret_kernel_value=0;
    while(1){
        local++;
        var_global_2--;



        asm volatile(
                "MOV r0, %0\n"       // Argument to SVC (say, number 5)
                "SVC #0x1\n"           // Trigger SVC 1 (write)
                :
                : "r"(local*2));
        
        asm volatile(
                "SVC #0x0\n"           // Trigger SVC 0 (read)
                "MOV %0, r0\n": "=r"(secret_kernel_value));       // Capture return value from r0 into result
    }
}