/**************** VARIABLES GLOBALES ********************/
.global _timer_init
.global _timer0_intclr
.global _handler_timer0
/********************************************************/

/***************** DEFINES ************************************************************************************/
.equ OFF_TIMER_LOAD,    0x00
.equ OFF_TIMER_VALUE,   0x04
.equ OFF_TIMER_CTRL,    0x08
.equ OFF_TIMER_INTCLR,  0x0C
.equ OFF_TIMER_RIS,     0x10
.equ OFF_TIMER_MIS,     0x14
.equ OFF_TIMER_BGLOAD,  0x18
/**************************************************************************************************************/

.code 32
.section .data_kernel,"ax"@progbits
    _TIMER0_BASE:   .word 0x10011000

.code 32
.section .text_kernel,"ax"@progbits
// Supongo que clock va a 1MHz. Sin div de clock.
_timer_init:
    LDR R4, =_TIMER0_BASE
    LDR R4, [R4]
    MOV R5, #10000              //Valor a cargar en el registro
    STR R5, [R4, #OFF_TIMER_LOAD]

    MOV R5, #0b11100010 //EMA, PERIODICO, IRQ, NO-DIV, 32Bits, Recarga 
    STR R5, [R4, #OFF_TIMER_CTRL]

    BX LR

_handler_timer0:              
    LDR R4, =_TIMER0_BASE
    LDR R4, [R4]
    MOV R5, #1
    STR R5, [R4, #OFF_TIMER_INTCLR]

    BX LR
    
.end
