#include <stdint.h>
#include "../../inc/global_variables.h"

/*__attribute__((section(".task1"))) void task1(){
    int volatile local = 0;
    while(1){
        local++;
        var_global_1++;
    }
}*/

extern uint32_t _TASK_1_READ_AREA_VMA;

__attribute__((section(".task1"))) void task1(){
    int volatile local = 0;
    uint32_t lectura = 0;  //valor leido en una posicion X de memoria.
    uint32_t saved = 0; //valor guardado antes de leer memoria (retiene valor).
    uint32_t sweep_task1 = 0;

    while(1)
    {
        local++;
        var_global_1++;

        uint32_t* rw_address = (uint32_t*)((uint32_t)&_TASK_1_READ_AREA_VMA + sweep_task1*4);
        saved = *rw_address;     //primero RETENGO el contenido de la direccion dada por sweep_task1. 
        *rw_address = 0x55AA55AA; //En el contenido de dicha direccion ESCRIBO 0x55AA55AA (patron de testeo).
        lectura = *rw_address;      //LEO lo que he escrito recien.
        
        if (lectura == 0x55AA55AA)
        {                                                  //VERIFICO la escirtura (si se leyo 0x55AA55AA es porque escribio bien eso).
            *rw_address = saved;  //restauro el valor original antes de sobreescribir.  
        }
        
        if(sweep_task1 >= (0x3FFF))  //0x70A0FFFC - 0x70A00000 = 0xFFFC => 0xFFFC/4 = 0x3FFF
            sweep_task1 = 0;
        else
            sweep_task1++;
    }
}