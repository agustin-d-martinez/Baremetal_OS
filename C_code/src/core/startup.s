.equ USR_MODE, 0x10
.equ FIQ_MODE, 0x11
.equ IRQ_MODE, 0x12
.equ SVC_MODE, 0x13
.equ ABT_MODE, 0x17
.equ UND_MODE, 0x1B
.equ SYS_MODE, 0x1F
.equ I_BIT, 0x80
.equ F_BIT, 0x40


.extern __irq_stack_top__
.extern __fiq_stack_top__
.extern __svc_stack_top__
.extern __abt_stack_top__
.extern __und_stack_top__
.extern __sys_stack_top__


.extern _reset_vector
.extern _UND_handler
.extern _SVC_handler
.extern _PREFETCH_handler
.extern _DATA_handler
.extern _IRQ_handler
.extern _FIQ_handler

.code 32

.global _start
.global _idle

.section .text
//Tabla de inicializacion de handlers
_table_start:
	LDR PC, add_reset_vector		//Esto funcionalmente es un branch a _reset_vector
	LDR PC, add_UND_handler
	LDR PC, add_SVC_handler
	LDR PC, add_PREFETCH_handler
	LDR PC, add_DATA_handler
	LDR PC, add_reset_vector		// Handler para espacio reservado
	LDR PC, add_IRQ_handler
	LDR PC, add_FIQ_handler

add_reset_vector: .word _reset_vector
add_UND_handler: .word _UND_handler
add_SVC_handler: .word _SVC_handler
add_PREFETCH_handler: .word _PREFETCH_handler
add_DATA_handler: .word _DATA_handler
add_IRQ_handler: .word _IRQ_handler
add_FIQ_handler: .word _FIQ_handler


_start:
	MOV R0, #0		//Inicia R0 en 0
	LDR R1, =_table_start	//Coloca en R1 el puntero a inicio de tabla
	LDR R2, =_start	//Coloca en R2 el puntero al fin de tabla
_TABLE_LOOP:
	LDR R3, [R1], #4	//Carga en R3 el contenido de R1, luego incrementa R1 en 4
	STR R3, [R0], #4	//Carga en el contenido de R0 el valor de R3, luego incrementa R0 en 4

	CMP R1, R2		//Compara si R1 llego a la finalizacion de la tabla, terminando el loop
	BNE _TABLE_LOOP		//si no llego a la finalizacion, loopear. sino, contiunar

_STACK_INIT:
	MSR cpsr_c, #(IRQ_MODE | I_BIT | F_BIT)
	LDR SP, =__irq_stack_top__ // IRQ STACK POINTER

	MSR cpsr_c, #(FIQ_MODE | I_BIT | F_BIT)
    LDR SP, =__fiq_stack_top__ // FIQ STACK POINTER

	MSR cpsr_c, #(ABT_MODE | I_BIT | F_BIT)
    LDR SP, =__abt_stack_top__ // ABT STACK POINTER

	MSR cpsr_c, #(SYS_MODE | I_BIT | F_BIT)
    LDR SP, =__sys_stack_top__ // SYS STACK POINTER

	MSR cpsr_c, #(UND_MODE | I_BIT | F_BIT)
    LDR SP, =__und_stack_top__ // UND STACK POINTER

	MSR cpsr_c, #(SVC_MODE | I_BIT | F_BIT)
    LDR SP, =__svc_stack_top__ // SVC STACK POINTER
								//Al inicializar, entra a modo SVC, por lo que debe volver al modo SVC

	LDR R10, =__gic_init
	MOV LR, PC  //Guarda en LR el opcode dos lineas delante por pipeline
	BX R10

	LDR R10, =__timer_init
	MOV LR, PC  //Guarda en LR el opcode dos lineas delante por pipeline
	BX R10

	LDR R10, =__move_lma_to_phy
	MOV LR, PC
	BX R10

	LDR R10, =__init_tcb
	MOV LR, PC  //Guarda en LR el opcode dos lineas delante por pipeline
	BX R10

	LDR R10, =__page_all
	MOV LR, PC  //Guarda en LR el opcode dos lineas delante por pipeline
	BX R10

_STACK_READY:
	// TTBR0 debe apuntar a la tabla de directorio de páginas.
	LDR R0,=_TTBR0_IDLE
    MCR p15, 0, R0, c2, c0, 0

	// (Comentado)Todos los dominios van a ser manager.
	// ARM tiene 16 dominios (cada dominio son 2 bits)
	// 00 NO ACCESS
	// 01 Configurar con AP (Flags de paginacion)
	// 10 Reserved (No usar nunca)
	// 11 Manager (Siempre disponible, ignora flags)
	// 0xFFFFFFFF significa 11 11 11 .... (ignorar flags paginacion)
	// 0x55555555 significa 01 01 01 .... (usar flags de paginacion)
    //LDR R0, =0xFFFFFFFF
	LDR R0, =0x55555555
    MCR p15, 0, R0, c3, c0, 0

	// Habilitar MMU
    MRC p15, 0,R1, c1, c0, 0    // Leer reg. control.
    ORR R1, R1, #0x1            // Bit 0 es habilitación de MMU.
    MCR p15, 0, R1, c1, c0, 0   // Escribir reg. 

	MRS R0, cpsr //Guarda en R0 el Current Program Status Register
	BIC R0,R0, #I_BIT	//BIC guarda en R0 el valor de R0 seteando en 0 los bits indicados
						//Esto Setea en 0 el interrupt, habilitandolo
	MSR cpsr_c, R0		//Guarda en el Current Program Status Register R0

_idle:
	WFI
	B _idle

.end
