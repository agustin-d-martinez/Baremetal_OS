/***************** HANDLERS DEL VECTOR DE INTERRUPCIONES ******************************************************/
.global _UND_handler
.global _SVC_handler
.global _Prefetch_handler
.global _Abort_handler
.global _IRQ_handler
.global _FIQ_handler
/**************************************************************************************************************/

/**************** VARIABLES EXTERNAS ********************/
.extern _gic_get_intID
.extern _gic_set_EOIR
.extern _scheduler
/********************************************************/

/***************** DEFINES DE CODES SVC ***********************************************************************/
/***** IRQ INTERRUPT ID ******/
.equ IRQ_ID_TIMER0, 36

/***** SVC CODES ******/
.equ SVC_CODE_SUMA, 0
.equ SVC_CODE_RESTA, 1

/***** ERROR MESSAJES ******/
.equ INV_ERROR,     0x00494E56 // "INV" en ASCII: I = 0x49, N = 0x4E, V = 0x56
.equ MEMORY_ERROR,  0x004D454D // "MEM" = M E M → 0x4D 0x45 0x4D
/**************************************************************************************************************/

.code 32
.section .text_kernel,"ax"@progbits
_UND_handler:		
    SUB LR, LR, #4
    PUSH {R0, R10}
    MOV R0, #0      
    STR R0, [LR]    //Reemplazo la instruccion de error (LR) por 0x00000000  
    LDR R10, =INV_ERROR
    POP {R0,R10}
    MOVS PC, LR     //Vuelvo y cambio de modo


_SVC_handler:
    PUSH {R5, LR}

    LDR R5, [LR,#-4]
    BIC R5, #0xFF000000     //Obtengo el opcode que usaron en svc

    CMP R5, #SVC_CODE_RESTA         //Verifico cond resta
    BEQ _SVC_resta
    CMP R5, #SVC_CODE_SUMA         //La ultima condicion se ejecuta si o si, verifico si irme antes.
    BNE _SVC_end
_SVC_suma:              //[R1,R0] = [R3,R2] + [R1,R0] 
    ADDS R0, R0, R2
    ADC R1, R1, R3
    B _SVC_end
_SVC_resta:             //[R1,R0] = [R3,R2] - [R1,R0] 
    SUBS R0, R2, R0
    SBC R1, R3, R1
    B _SVC_end
_SVC_end:
    POP {R5, LR}
    MOVS PC, LR


_Prefetch_handler:	
    SUB LR, LR, #4
    PUSH {R10}
    LDR R10, =MEMORY_ERROR
    POP {R10}

    MOVS PC, LR


_Abort_handler:		
    SUB LR, LR, #8
    PUSH {R10}
    LDR R10, =MEMORY_ERROR
    POP {R10}

    MOVS PC, LR


_IRQ_handler:
    SUB LR, LR, #4				//Resto 1 word al LR para regresar al lugar correcto
    PUSH {R0-R12, LR}
    
    BL _gic_get_intID

    CMP R0, #IRQ_ID_TIMER0
    BLEQ _scheduler
    MOV R0, #IRQ_ID_TIMER0

    //Aca se realizarian mas CMP de ser necesarios. y sus llamadas a handler

    BL _gic_set_EOIR    

    POP {R0-R12, LR}
    MOVS PC, LR

_FIQ_handler:
    SUB lr, lr, #4				//Resto 1 word al LR para regresar al lugar correcto
    B .

.end
