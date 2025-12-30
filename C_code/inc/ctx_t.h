#include <stdint.h>

typedef struct ctx_t{
    uint32_t spsr, gpr[ 13 ], *lr;
} ctx_t;