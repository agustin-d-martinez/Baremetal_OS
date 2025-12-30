.global _UND_handler
.global _SVC_handler
.global _PREFETCH_handler
.global _DATA_handler
.global _IRQ_handler
.global _FIQ_handler

.code 32

.section .text_handlers

_UND_handler:
	WFI
	b _UND_handler

_SVC_handler:
	// r0 a r2 esta reservado para pasar variables
	// se debe mover r0 a r2 a r1 a r3 (r0 tendra el SVC IMM)
	stmfd sp!, { r3-r12, lr}	// Guardar en el stack full desending los registros (sp = base address, ! = decrement automatically sp)
	mrs r8, spsr				// Guardar Saved Program Status Register
	push {r8}					// Pushear spsr al stack

	mov r3, r2
	mov r2, r1
	mov r1, r0
	ldr r0, [lr, #-4]
	bic r0, r0, #0xFF000000

	bl kernel_handler_svc		// handler c

	mov r1,r2
	mov r2,r3
	pop {r8}
	msr spsr, r8
	ldmfd sp!, {r3-r12, pc}^ 	//Coloca el Link Register en el Program Counter
								//^ Loads spsr (Saved Program Status Register) in cpsr (Current Program Status Register) at the end of execution

_PREFETCH_handler:
	WFI
	b _PREFETCH_handler

_DATA_handler:
	WFI
	b _DATA_handler

_IRQ_handler:
	sub lr, lr, #4				//Le resta 4 al LR. Por pipeline, esto hace que vuelva a la instruccion siguiente a la que se estaba ejecutando en el interrupt
	stmfd sp!, { r0-r12, lr}	// Guardar en el stack full desending los registros (sp = base address, ! = decrement automatically sp)
	mrs r8, spsr				// Guardar Saved Program Status Register
	push {r8}					// Pushear spsr al stack

	mov r0, sp					// enviar ctx al handler
	bl kernel_handler_irq		// handler c
	mov sp, r0					// Recibir ctx

	pop {r8}
	msr spsr, r8
	ldmfd sp!, {r0-r12, pc}^ 	//Coloca el Link Register en el Program Counter
								//^ Loads spsr (Saved Program Status Register) in cpsr (Current Program Status Register) at the end of execution

_FIQ_handler:
	sub lr, lr, #4
	stmfd sp!, { r0-r12, lr}
	mrs r8, spsr
	push {r8}

	mov r0, sp
	bl kernel_handler_irq
	mov sp, r0
	
	pop {r8}
	msr spsr, r8
	ldmfd sp!, {r0-r12, pc}^ 	//Coloca el Link Register en el Program Counter
								//^ Loads spsr (Saved Program Status Register) in cpsr (Current Program Status Register) at the end of execution
