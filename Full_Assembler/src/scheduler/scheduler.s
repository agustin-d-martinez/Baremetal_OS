/**************** VARIABLES GLOBALES ********************/
.global _scheduler
.global _pcb_init
/********************************************************/
/**************** VARIABLES EXTERNAS ********************/
.extern _handler_timer0

.extern __svc_stack_top__
.extern __TASK1_stack_top__
.extern __TASK2_stack_top__

.extern _app_start
.extern _task1
.extern _task2
/********************************************************/
/***************** DEFINES ************************************************************************************/
.equ START_PCB,         0x8200EC00  //Debe estar luego de las tablas de paginacion!!!!
.equ TTBR0_KERNEL,      0x82000000
.equ TTBR0_TASK1,       0x82004000  //Checkear!!!!!
.equ TTBR0_TASK2,       0x82008000

.equ OFF_STATE,         0x04
.equ OFF_TTBRO,         0x08
.equ OFF_R0,            0x0C
.equ OFF_CPSR,          0x4C
.equ OFF_ID,            0x50
.equ OFF_TIMEFRAME,     0x54
.equ PCB_SIZE,          0x58

.equ PENDING_STATE,     0x0
.equ ACTIVE_STATE,      0x1
/**************************************************************************************************************/
.code 32
.section .data_kernel,"ax"@progbits
    current_pcb_dir:    .word 0x00000000
    _TIMER_COUNT:       .word 0x00000000

.code 32
.section boot,"ax"@progbits
_scheduler:
//----Chequeo time frame
    LDR R4, =_TIMER_COUNT
    LDR R5, [R4]
    ADD R5, R5, #1

    LDR R0, =current_pcb_dir
    LDR R0, [R0]
    LDR R1, [R0, #OFF_TIMEFRAME]
    CMP R1, R5

    MOVEQ R5, #0
    STR R5, [R4]            //Guardo en timercount el valor del timer
    BNE _end_scheduler

//--Context switch tarea vieja
    ADD R1, R0, #OFF_R0
    POP {R2-R5}
    STMIA R1!, {R2-R5}  //guardo R0,R1,R2,R3
    
    POP {R2-R11}
    STMIA R1!, {R2-R11} //Guardo R4,R5,R6,R7,R8,R9,R10,R11,R12,PC (era el LR_irq)

    CPS #0x13
    STR LR, [R1], #4
    STR SP, [R1], #4
    CPS #0x12           //Guardo LR y SP (debo cambiar de modo)
                        
    MRS R2, SPSR
    STR R2, [R1], #4   //Guardo CPSR (se encontraba en SPSR)

//--Busco tarea nueva
    MOV R1, #PENDING_STATE
    STR R1, [R0, #OFF_STATE]    //Cambio estado task vieja

_serch_new_task:
    LDR R0, [R0]
    LDR R1, [R0, #OFF_STATE]
    CMP R1, #PENDING_STATE  //Busco la nueva tarea en estado pending
    BNE _serch_new_task

    MOV R1, #ACTIVE_STATE
    STR R1, [R0, #OFF_STATE]

    LDR R1, =current_pcb_dir
    STR R0, [R1]

//--Context switch tarea nueva
    ADD R1, R0, #OFF_CPSR

    LDR R2, [R1], #-4
    MSR SPSR, R2

    CPS #0x13
    LDR R2, [R1], #-4
    MOV SP, R2
    LDR R2, [R1]
    MOV LR, R2
    CPS #0x12

    LDMDB R1!, {R2-R11}
    PUSH {R2-R11}

    LDMDB R1!, {R2-R5}
    PUSH {R2-R5}

//-- Cambiar tabla paginacion
    MOV R1, #0
    MRC p15, 0, R1, c13, c0, 1  //ASID A 0
    ISB

    LDR R1, [R0, #OFF_TTBRO]
    ADD R1, R1, #1
    MCR p15, 0, R1, c2, c0, 0   //TTBR0
    ISB

    LDR R1, [R0, #OFF_ID]
    ORR R1, R1, R1, LSL #8  //PROCID + ASID
    MCR p15, 0, R1, c13, c0, 1  //ASID A NEW ASID

_end_scheduler: //--Me voy
    PUSH {LR}
    BL _handler_timer0
    POP {LR}
    BX LR


_pcb_init:
    PUSH {LR}

    LDR R0, =START_PCB
    LDR R1, =current_pcb_dir
    STR R0, [R1]

    ADD R1, R0, #PCB_SIZE
    MOV R2, #ACTIVE_STATE
    LDR R3, =TTBR0_KERNEL
    LDR R4, =_app_start
    LDR R5, =__svc_stack_top__
    MRS R6, CPSR
    MOV R7, #0
    MOV R8, #2
    BL _create_pcb  //Task Kernel

    ADD R1, R0, #PCB_SIZE
    MOV R2, #PENDING_STATE
    LDR R3, =TTBR0_TASK1
    LDR R4, =_task1
    LDR R5, =__TASK1_stack_top__
    //MRS R6, CPSR
    MOV R7, #1
    MOV R8, #2
    BL _create_pcb  //Task 1

    SUB R1, R0, #PCB_SIZE*2
    MOV R2, #PENDING_STATE
    LDR R3, =TTBR0_TASK2
    LDR R4, =_task2
    LDR R5, =__TASK2_stack_top__
    //MRS R6, CPSR
    MOV R7, #2
    MOV R8, #2
    BL _create_pcb  //Task 2
    
    POP {LR}
    BX LR

_create_pcb:
    STR R1, [R0], #4    //Dir next PCB
    STR R2, [R0], #4    //State
    STR R3, [R0], #14*4 //TTBR0
    STR R4, [R0], #2*4  //PC
    STR R5, [R0], #4    //SP
    STR R6, [R0], #4    //CPSR
    STR R7, [R0], #4    //ID
    STR R8, [R0], #4    //Time Frame

    BX LR

.end

/* Estructura de PCB:
    - DIR NEXT PCB      [+0]        <-- DIR CURRENT PCB
    - STATE             [+4]
    - TTBR0             [+8]
    - R0                [+C]
    - R1
    - R2
    - R3
    - R4
    - R5
    - R6
    - R7
    - R8
    - R9
    - R10
    - R11
    - R12
    - PC (R15)
    - LR (R14)
    - SP (R13)
    - CPSR              [+4C]
    - ID (ALSO ASID) (VALID WITH LESS THAN 256 TASKS)   [+50]
    - TIME FRAME        [+54]

    SIZE: 22 WORDS -> 88 BYTES  ->  0x58
    UBICATION: NEXT TO PAGINATION TABLES (TABLE_END)
 */
