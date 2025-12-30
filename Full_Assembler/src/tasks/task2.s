/**************** VARIABLES GLOBALES ********************/
.global _task2
/********************************************************/
.extern __bss_task2_start__
/***************** DEFINES ************************************************************************************/
.equ _READ_START,   __bss_task2_start__
.equ _READ_END,     __bss_task2_start__ + 0x400
/**************************************************************************************************************/

/*FUNCTION:
    R0: ACTUAL_DIR
    R1: END_DIR
    R2: AUX WORD
*/

.code 32
.section .task2,"ax"@progbits
_task2:
    LDR R0, =_READ_START
    LDR R1, =_READ_END

loop:     
    LDR R2, [R0]        //Leo actual
    MVN R2, R2 
    STR R2, [R0, #4]!

    CMP R0, R1
    LDREQ R0, =_READ_START

    B loop

.end
