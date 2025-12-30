#include <stdint.h>
#include "../../inc/global_variables.h"

__attribute__((section(".task3"))) void task3(){
    while(1){
        var_global_1--;
        var_global_2++;
    }
}