/**************** VARIABLES GLOBALES ********************/
.global _task1
/********************************************************/
.extern __bss_task1_start__

/***************** DEFINES ************************************************************************************/
.equ _READ_START,   __bss_task1_start__
.equ _READ_END,     __bss_task1_start__ + 0x400
/**************************************************************************************************************/

.code 32
.section .data_task1,"ax"@progbits
    ERROR:    .word 0x00000000

/*FUNCTION:
    R0: ACTUAL_DIR
    R1: END_DIR
    R2: KEY WORD
    R3: READED WORD
    R4: ERROR DIR
    R5: CANT. ERROR 
*/

.code 32
.section .task1,"ax"@progbits
_task1:
    LDR R0, =_READ_START
    LDR R1, =_READ_END

    MOV  R2, #0x55AA    //R2 = 0x55AA55AA
    MOVT R2, #0x55AA      

    STR R2, [R0]
    LDR R4, =ERROR
    MOV R5, #0
loop:     
    LDR R3, [R0], #4        //Leo actual

    CMP R2, R3              //Sumo error
    ADDNE R5, R5, #1
    STR R5, [R4]

    CMP R0, R1
    LDREQ R0, =_READ_START

    STR R2, [R0]
    B loop

.end
