/***************** EXTERNS DE HANDLERS ************************************************************************/
.extern _UND_handler
.extern _SVC_handler
.extern _Prefetch_handler
.extern _Abort_handler
.extern _IRQ_handler
.extern _FIQ_handler
.extern _start
/**************************************************************************************************************/

.code 32
.section reset_vector,"ax"@progbits
      LDR PC, add_RESET_vector     //Corresponde al "reset vector"
      LDR PC, add_UND_vector    //Copio un salto de PC a la direcciòn del verdadero handler
      LDR PC, add_SVC_vector
      LDR PC, add_Prefetch_vector
      LDR PC, add_Abort_vector
      NOP	                    //Corresponde al "reserved"
      LDR PC, add_IRQ_vector
      LDR PC, add_FIQ_vector

      add_RESET_vector:		.word	_start		      //<dir de inicio de boot>
      add_UND_vector:		.word	_UND_handler		//<dir de undefined>
      add_SVC_vector:		.word	_SVC_handler		//<dir de SVC handler>
      add_Prefetch_vector:    .word	_Prefetch_handler	      //<dir de Prefetch handler>
      add_Abort_vector:	      .word	_Abort_handler		//<dir de Data Abort handler>
      add_IRQ_vector:		.word	_IRQ_handler		//<dir de Irq handler>
      add_FIQ_vector:		.word	_FIQ_handler		//<dir de Irq handler>

.end
