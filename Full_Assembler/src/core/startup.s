/**************** PUNTO DE ENTRADA **********************/
.global _start

/***************** EXTERNS DE MAPA DE MEMORIA *****************************************************************/
.extern __reset_vector_LMA__
.extern __reset_vector_size__
.extern __reset_vector_PADDR__

.extern __text_kernel_size__
.extern __text_kernel_size__
.extern __text_kernel_PADDR__

.extern __data_kernel_LMA__
.extern __data_kernel_size__
.extern __data_kernel_PADDR__

.extern __data_task1_LMA__
.extern __data_task1_size__
.extern __data_task1_PADDR__

.extern __data_task2_LMA__
.extern __data_task2_size__
.extern __data_task2_PADDR__

.extern __task1_LMA__
.extern __task1_size__
.extern __task1_PADDR__

.extern __task2_LMA__
.extern __task2_size__
.extern __task2_PADDR__

.extern __sys_stack_top__
.extern __irq_stack_top__
.extern __fiq_stack_top__
.extern __svc_stack_top__
.extern __abt_stack_top__
.extern __und_stack_top__
/**************************************************************************************************************/

/**************** VARIABLES EXTERNAS ********************/
.extern _app_start
.extern _gic_init
.extern _timer_init
.extern _paginacion
.extern _pcb_init

/***************** DEFINES ************************************************************************************/
.equ USR_MODE, 0x10
.equ FIQ_MODE, 0x11
.equ IRQ_MODE, 0x12
.equ SVC_MODE, 0x13
.equ ABT_MODE, 0x17
.equ UND_MODE, 0x1B
.equ SYS_MODE, 0x1F
/**************************************************************************************************************/

.code 32
.section boot,"ax"@progbits
_start:
//-------------------Copio secciones de memoria-------------------------
      LDR R0, =__reset_vector_LMA__       //puntero Origen
      LDR R1, =__reset_vector_PADDR__     //puntero Destino
      LDR R2, =__reset_vector_size__      //size
      BL _move_paddr                      //Copia de la region reset_vector a su PADDR

      LDR R0, =__text_kernel_LMA__
      LDR R1, =__text_kernel_PADDR__
      LDR R2, =__text_kernel_size__
      BL _move_paddr                      //Copia de la region kernel_text a su PADDR

      LDR R0, =__data_kernel_LMA__
      LDR R1, =__data_kernel_PADDR__
      LDR R2, =__data_kernel_size__
      BL _move_paddr                      //Copia de la region .data a su PADDR

      LDR R0, =__data_task1_LMA__
      LDR R1, =__data_task1_PADDR__
      LDR R2, =__data_task1_size__
      BL _move_paddr                      //Copia las regiones de task a su PADDR 

      LDR R0, =__data_task2_LMA__
      LDR R1, =__data_task2_PADDR__
      LDR R2, =__data_task2_size__
      BL _move_paddr

      LDR R0, =__task1_LMA__
      LDR R1, =__task1_PADDR__
      LDR R2, =__task1_size__
      BL _move_paddr

      LDR R0, =__task2_LMA__
      LDR R1, =__task2_PADDR__
      LDR R2, =__task2_size__
      BL _move_paddr

//------------------ Inicializo PAG ----------------------------------------
      LDR R10, =_paginacion
      BLX R10

//------Inicializo todos los stacks -----------------------------------
      CPSID aif, #IRQ_MODE
      LDR SP, =__irq_stack_top__          //Cambiamos el modo y hacemos un load al valor de sp de dicho modo

      CPSID aif, #FIQ_MODE
      LDR SP, =__fiq_stack_top__

      CPSID aif, #ABT_MODE
      LDR SP, =__abt_stack_top__

      CPSID aif, #UND_MODE
      LDR SP, =__und_stack_top__

      CPSID aif, #SYS_MODE
      LDR SP, =__sys_stack_top__
      
      CPSID aif, #SVC_MODE
      LDR SP, =__svc_stack_top__

      CPSIE aif

//------------------ Inicializo PCB ----------------------------------------
      LDR R10, =_pcb_init
      BLX R10

      CPSID if

//------------------ Inicializo TIMER0 -------------------------------------
      LDR R10, =_timer_init
      BLX R10

//------------------ Inicializo GIC ----------------------------------------
      LDR R10, =_gic_init
      BLX R10
      
//------------------ Salto a app -------------------------------------------
      CPSIE aif   //Habilito interrupciones
      LDR R0, =_app_start
      BX R0

//------------------ Funcion para copiado de bloques de memoria -----------
_move_paddr://R0: Origen, R1: destino, R2: size
      CMP R2, #0
      BEQ _end_move_paddr     //SI R2 es 0 me voy. R2 es unsigned.
_loop:
      LDRB R3, [R0], #1       //Contenido Origen.
      STRB R3 , [R1], #1      //Copio en el destino. Copio de a Bytes por si no todo son WORDS de 4 Bytes.
      SUBS R2 , #1
      BNE _loop              
_end_move_paddr:
      MOV PC, LR
.end
