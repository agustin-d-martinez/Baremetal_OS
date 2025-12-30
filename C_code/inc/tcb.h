#include <stdint.h>

typedef struct tcb_t{
    uint32_t* sp_irq;
    uint32_t* sp_svc;
    uint32_t* sp_sys;
    uint32_t ticks;
    uint32_t* ttrb0;
    uint32_t* lr_svc;
    uint32_t* lr_sys;
    uint32_t  usr_mode;
} tcb_t;