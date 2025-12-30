/***************** DECLARACIONES DE FUNCIONES *****************************************************************/
.global _gic_init
.global _gic_get_intID
.global _gic_set_EOIR
/**************************************************************************************************************/

/***************** DEFINES ************************************************************************************/
.equ OFF_GIC_CTRL,   0x00
.equ OFF_GIC_PMR,    0x04
.equ OFF_GIC_BPR,    0x08
.equ OFF_GIC_IAR,    0x0C
.equ OFF_GIC_EOIR,   0x10
.equ OFF_GIC_RPR,    0x14
.equ OFF_GIC_HPPIR,  0x18

.equ OFF_GID_CTRL,      0x000
.equ OFF_GID_TYPER,     0x004
.equ OFF_GID_ISENABLER0,0x100
.equ OFF_GID_ISENABLER1,0x104
.equ OFF_GID_ISENABLER2,0x108
.equ OFF_GID_ICENABLER, 0x180
.equ OFF_GID_ISPENDR,   0x200
.equ OFF_GID_ICPENDR,   0x280
.equ OFF_GID_ISACTIVER, 0x300
.equ OFF_GID_IPRIORITYR,0x400
.equ OFF_GID_ITARGETSR, 0x800
.equ OFF_GID_ICFGR,     0xC00
.equ OFF_GID_SGIR,      0xF00
/**************************************************************************************************************/

.code 32
.section .data_kernel,"ax"@progbits
_GICC0_BASE: .word 0x1E000000
_GICD0_BASE: .word 0x1E001000

.code 32
.section .text_kernel,"ax"@progbits
_gic_init:
    LDR R4, =_GICD0_BASE
    LDR R4, [R4]
    LDR R5, [R4, #OFF_GID_ISENABLER1]
    ORR R5, R5, #0x10       //GID0->ISENABLER[1] |= 0x10
    STR R5, [R4, #OFF_GID_ISENABLER1]
    MOV R5, #1              
    STR R5, [R4, #OFF_GID_CTRL]            //GID0->CTRL = 1

    LDR R4, =_GICC0_BASE
    LDR R4, [R4]
    MOV R5, #0xF0           //GIC0->PMR = 0xF0
    STR R5, [R4, #OFF_GIC_PMR]

    MOV R5, #1              //GIC0->CTRL = 1
    STR R5, [R4, #OFF_GIC_CTRL]


    BX LR

_gic_get_intID:
    LDR R4, =_GICC0_BASE
    LDR R4, [R4]
    LDR R0, [R4, #OFF_GIC_IAR]          // <-- Devuelvo el ID en R0

    MOV PC, LR

_gic_set_EOIR:
    LDR R4, =_GICC0_BASE
    LDR R4, [R4]
    STR R0, [R4, #OFF_GIC_EOIR]         // <-- Coloco el valor de R0 en EOIR

    BX LR

.end
