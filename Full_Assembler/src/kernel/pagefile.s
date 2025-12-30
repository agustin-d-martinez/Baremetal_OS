/**************** VARIABLES GLOBALES ********************/
.global _paginacion
/********************************************************/

/**************** VARIABLES EXTERNAS ********************/
.extern __reset_vector_start__
.extern __reset_vector_PADDR__
.extern __reset_vector_size__

.extern __boot_start__
.extern __boot_PADDR__
.extern __boot_size__

.extern __text_kernel_start__
.extern __text_kernel_PADDR__
.extern __text_kernel_size__

.extern __data_kernel_start__
.extern __data_kernel_PADDR__
.extern __data_kernel_size__

.extern __bss_kernel_start__
.extern __bss_kernel_PADDR__
.extern __bss_kernel_size__

.extern __stack_start__
.extern __stack_PADDR__
.extern __stack_size__

.extern __task1_start__
.extern __task1_PADDR__
.extern __task1_size__

.extern __data_task1_start__
.extern __data_task1_PADDR__
.extern __data_task1_size__

.extern __bss_task1_start__
.extern __bss_task1_PADDR__
.extern __bss_task1_size__

.extern __task2_start__
.extern __task2_PADDR__
.extern __task2_size__

.extern __data_task2_start__
.extern __data_task2_PADDR__
.extern __data_task2_size__

.extern __bss_task2_start__
.extern __bss_task2_PADDR__
.extern __bss_task2_size__
/********************************************************/

/**************** DEFINES *******************************/
.equ TABLE_LVL1_KERNEL, __bss_kernel_start__
.equ TABLE_LVL1_TASK1,  TABLE_LVL1_KERNEL + 0x4000
.equ TABLE_LVL1_TASK2,  TABLE_LVL1_TASK1 + 0x4000

.equ TABLE_LVL2_INTRP,  TABLE_LVL1_TASK2 + 0x4000     /*Offset 0x000. Reset vector.*/

.equ TABLE_LVL2_TEXTK,  TABLE_LVL2_INTRP + 0x400      /*Offset 0x700. Use for Kernel, stack, task_test, data_task.*/
.equ TABLE_LVL2_TEXT1,  TABLE_LVL2_TEXTK + 0x400      /*Offset 0x700. Same to task1 */
.equ TABLE_LVL2_TEXT2,  TABLE_LVL2_TEXT1 + 0x400      /*Offset 0x700. Same to task2 */

.equ TABLE_LVL2_DATAK,  TABLE_LVL2_TEXT2 + 0x400      /*Offset 0x810. Use for data_kernel.*/

.equ TABLE_LVL2_BSST1,  TABLE_LVL2_DATAK + 0x400      /*Offset 0x701. Use for bss_task1.*/
.equ TABLE_LVL2_BSST2,  TABLE_LVL2_BSST1 + 0x400      /*Offset 0x701. Use for bss_task2.*/
.equ TABLE_LVL2_BSSK,   TABLE_LVL2_BSST2 + 0x400      /*Offset 0x820. Use for bss_kernel.*/

.equ TABLA_LVL2_PERIPH, TABLE_LVL2_BSSK + 0x400       /*Offset 0x100. From Datasheet.*/
.equ TABLE_LVL2_GIC,    TABLA_LVL2_PERIPH + 0x400     /*Offset 0x1E0. From Datasheet.*/

.equ TABLE_END, TABLE_LVL2_GIC + 0x400


.equ __periphepal_start__,    0x10000000  //Datasheet
.equ __periphepal_end__,      0x10020000

.equ __gic_start__,           0x1E000000  //Datasheet
.equ __gic_end__,             0x1E020000

.equ nG,          0x800
.equ Small_Page,  0x2
.equ XN,          0x1
.equ RW_RW,       0x30  //[PL1]_[PL0] -> [Privilegated]_[User]
.equ RW_R,        0x20
.equ RW_None,     0x10
.equ R_R,         0x130
.equ R_None,      0x110
/********************************************************/

.code 32
.section boot,"ax"@progbits
_paginacion: 
      MOV R12, LR       //Voy a usar a R12 para volver ya que los stacks aun no estan paginados.

//------ Limpio las paginas --------------------------------------------
      MOV R0, #0
      LDR R1, =TABLE_LVL1_KERNEL
      LDR R2, =TABLE_END
ciclo_borrado:
      STRB R0, [R1], #1
      CMP R1, R2
      BNE ciclo_borrado

//------ Creo las paginas de Kernel ----------------------------------------------
      LDR R0, =TABLE_LVL1_KERNEL + 0x000*4       //Tabla LVL1 para vector de irq. Todo en offset 0x000
      LDR R1, =TABLE_LVL2_INTRP + 1      
      STR R1, [R0]      //R0: [TAbla LVL1 + OFFSET]. R1:[tabla LVL2 + FLAGS]

      LDR R0, =__reset_vector_start__
      LDR R1, =__reset_vector_size__
      LDR R2, =__reset_vector_PADDR__
      LDR R3, =TABLE_LVL2_INTRP
      MOV R4, #RW_RW + Small_Page
      BL paging_lvl2            //LVL2 para Vector de IRQ.

      LDR R0, =TABLE_LVL1_KERNEL + 0x700*4       //Tabla LVL1 para kernel. Todo en offset 0x700
      LDR R1, =TABLE_LVL2_TEXTK + 1      
      STR R1, [R0]      //Escribo Pagina LVL1

      LDR R0, =__boot_start__
      LDR R1, =__boot_size__
      LDR R2, =__boot_PADDR__
      LDR R3, =TABLE_LVL2_TEXTK
      BL paging_lvl2

      LDR R0, =__text_kernel_start__
      LDR R1, =__text_kernel_size__
      LDR R2, =__text_kernel_PADDR__
      LDR R3, =TABLE_LVL2_TEXTK
      BL paging_lvl2

      LDR R0, =__stack_start__
      LDR R1, =__stack_size__
      LDR R2, =__stack_PADDR__
      LDR R3, =TABLE_LVL2_TEXTK
      BL paging_lvl2

      LDR R0, =TABLE_LVL1_KERNEL + 0x810*4       //Tabla LVL1 para data. Todo en offset 0x810
      LDR R1, =TABLE_LVL2_DATAK + 1
      STR R1, [R0]

      LDR R0, =__data_kernel_start__
      LDR R1, =__data_kernel_size__
      LDR R2, =__data_kernel_PADDR__
      LDR R3, =TABLE_LVL2_DATAK
      BL paging_lvl2

      LDR R0, =TABLE_LVL1_KERNEL + 0x820*4       //Tabla LVL1 para bss kernel. Todo en offset 0x820
      LDR R1, =TABLE_LVL2_BSSK + 1
      STR R1, [R0]

      LDR R0, =__bss_kernel_start__
      LDR R1, =__bss_kernel_size__
      LDR R2, =__bss_kernel_PADDR__
      LDR R3, =TABLE_LVL2_BSSK
      BL paging_lvl2

      LDR R0, =TABLE_LVL1_KERNEL + 0x100*4       //Tabla LVL1 para perifericos. Todo en offset 0x100
      LDR R1, =TABLA_LVL2_PERIPH + 1      
      STR R1, [R0]

      LDR R0, =__periphepal_start__
      LDR R1, =__periphepal_end__ - __periphepal_start__
      LDR R2, =__periphepal_start__
      LDR R3, =TABLA_LVL2_PERIPH
      BL paging_lvl2

      LDR R0, =TABLE_LVL1_KERNEL + 0x1E0*4       //Tabla LVL1 para perifericos. Todo en offset 0x100
      LDR R1, =TABLE_LVL2_GIC + 1
      STR R1, [R0]      //Escribo Pagina LVL1

      LDR R0, =__gic_start__
      LDR R1, =__gic_end__ - __gic_start__
      LDR R2, =__gic_start__
      LDR R3, =TABLE_LVL2_GIC
      BL paging_lvl2

//------ Creo las paginas de TASK1 ----------------------------------------------
      LDR R0, =TABLE_LVL1_TASK1 + 0x000*4       //Interrupt
      LDR R1, =TABLE_LVL2_INTRP + 1
      STR R1, [R0]
      LDR R0, =TABLE_LVL1_TASK1 + 0x810*4       //Data kernel
      LDR R1, =TABLE_LVL2_DATAK + 1
      STR R1, [R0]
      LDR R0, =TABLE_LVL1_TASK1 + 0x820*4       //BSS Kernel
      LDR R1, =TABLE_LVL2_BSSK + 1
      STR R1, [R0]
      LDR R0, =TABLE_LVL1_TASK1 + 0x100*4       //Perifericos
      LDR R1, =TABLA_LVL2_PERIPH + 1
      STR R1, [R0]
      LDR R0, =TABLE_LVL1_TASK1 + 0x1E0*4       //Gic
      LDR R1, =TABLE_LVL2_GIC + 1
      STR R1, [R0]

      LDR R0, =TABLE_LVL1_TASK1 + 0x700*4       //kernel, text, data, stack.
      LDR R1, =TABLE_LVL2_TEXT1 + 1
      STR R1, [R0]
      LDR R0, =__boot_start__
      LDR R1, =__boot_size__
      LDR R2, =__boot_PADDR__
      LDR R3, =TABLE_LVL2_TEXT1
      MOV R4, #RW_RW + Small_Page
      BL paging_lvl2
      LDR R0, =__text_kernel_start__
      LDR R1, =__text_kernel_size__
      LDR R2, =__text_kernel_PADDR__
      LDR R3, =TABLE_LVL2_TEXT1
      MOV R4, #RW_RW + Small_Page
      BL paging_lvl2
      LDR R0, =__stack_start__
      LDR R1, =__stack_size__
      LDR R2, =__stack_PADDR__
      LDR R3, =TABLE_LVL2_TEXT1
      MOV R4, #RW_RW + Small_Page
      BL paging_lvl2    
      LDR R0, =__task1_start__
      LDR R1, =__task1_size__
      LDR R2, =__task1_PADDR__
      LDR R3, =TABLE_LVL2_TEXT1
      MOV R4, #RW_RW + Small_Page + nG
      BL paging_lvl2
      LDR R0, =__data_task1_start__
      LDR R1, =__data_task1_size__
      LDR R2, =__data_task1_PADDR__
      LDR R3, =TABLE_LVL2_TEXT1
      MOV R4, #RW_RW + Small_Page + nG
      BL paging_lvl2

      LDR R0, =TABLE_LVL1_TASK1 + 0x701*4       //BSS TASK1
      LDR R1, =TABLE_LVL2_BSST1 + 1
      STR R1, [R0]
      LDR R0, =__bss_task1_start__
      LDR R1, =__bss_task1_size__
      LDR R2, =__bss_task1_PADDR__
      LDR R3, =TABLE_LVL2_BSST1
      MOV R4, #RW_RW + Small_Page + nG
      BL paging_lvl2

//------ Creo las paginas de TASK2 ----------------------------------------------
      LDR R0, =TABLE_LVL1_TASK2 + 0x000*4       //Interrupt
      LDR R1, =TABLE_LVL2_INTRP + 1
      STR R1, [R0]
      LDR R0, =TABLE_LVL1_TASK2 + 0x810*4       //Data kernel
      LDR R1, =TABLE_LVL2_DATAK + 1
      STR R1, [R0]
      LDR R0, =TABLE_LVL1_TASK2 + 0x820*4       //BSS Kernel
      LDR R1, =TABLE_LVL2_BSSK + 1
      STR R1, [R0]
      LDR R0, =TABLE_LVL1_TASK2 + 0x100*4       //Perifericos
      LDR R1, =TABLA_LVL2_PERIPH + 1
      STR R1, [R0]
      LDR R0, =TABLE_LVL1_TASK2 + 0x1E0*4       //Gic
      LDR R1, =TABLE_LVL2_GIC + 1
      STR R1, [R0]

      LDR R0, =TABLE_LVL1_TASK2 + 0x700*4       //kernel, text, data, stack.
      LDR R1, =TABLE_LVL2_TEXT2 + 1
      STR R1, [R0]
      LDR R0, =__boot_start__
      LDR R1, =__boot_size__
      LDR R2, =__boot_PADDR__
      LDR R3, =TABLE_LVL2_TEXT2
      MOV R4, #RW_RW + Small_Page
      BL paging_lvl2
      LDR R0, =__text_kernel_start__
      LDR R1, =__text_kernel_size__
      LDR R2, =__text_kernel_PADDR__
      LDR R3, =TABLE_LVL2_TEXT2
      MOV R4, #RW_RW + Small_Page
      BL paging_lvl2
      LDR R0, =__stack_start__
      LDR R1, =__stack_size__
      LDR R2, =__stack_PADDR__
      LDR R3, =TABLE_LVL2_TEXT2
      MOV R4, #RW_RW + Small_Page
      BL paging_lvl2    
      LDR R0, =__task2_start__
      LDR R1, =__task2_size__
      LDR R2, =__task2_PADDR__
      LDR R3, =TABLE_LVL2_TEXT2
      MOV R4, #RW_RW + Small_Page + nG
      BL paging_lvl2
      LDR R0, =__data_task2_start__
      LDR R1, =__data_task2_size__
      LDR R2, =__data_task2_PADDR__
      LDR R3, =TABLE_LVL2_TEXT2
      MOV R4, #RW_RW + Small_Page + nG
      BL paging_lvl2

      LDR R0, =TABLE_LVL1_TASK2 + 0x701*4       //BSS TASK1
      LDR R1, =TABLE_LVL2_BSST2 + 1
      STR R1, [R0]
      LDR R0, =__bss_task2_start__
      LDR R1, =__bss_task2_size__
      LDR R2, =__bss_task2_PADDR__
      LDR R3, =TABLE_LVL2_BSST2
      MOV R4, #RW_RW + Small_Page + nG
      BL paging_lvl2

//------ Inicializo TTBCR(config TTBR0) --------------------------------
      MOV R0, #0
      MCR p15, 0, R0, c2, c0, 2
//------ Inicializo TTBR0 ----------------------------------------------
      LDR R0,=TABLE_LVL1_KERNEL + 1
      MCR p15, 0, R0, c2, c0, 0
//------ Habilito MMU --------------------------------------------------
      LDR R0, =0x55555555           // Todos los dominios van a ser cliente.
      MCR p15, 0, R0, c3, c0, 0

      MRC p15, 0, R1, c1, c0, 0     // Leer reg. control.
      ORR R1, R1, #(0x1 << 29)
      ORR R1, R1, #1            
      MCR p15, 0, R1, c1, c0, 0     // HAbilito MMU y AFE

      MOV LR, R12
      BX LR

// paging_lvl2( R0: DIR_INICIAL, R1: SIZE, R2: PADDR, R3: TABLE_LVL2, R4: FLAGS )
// Todo debe entrar en una sola pag lvl2. SIno no entra
paging_lvl2:
      MOV R5, #0xFFF
      ADD R1, R1, R5 
      LSR R1, R1, #12         //cant pags

      CMP R1, #0              //Si hay 0 paginas a hacer, me voy
      BXEQ LR

      BIC R0, R0, R5
      LSR R0, R0, #12
      AND R0, R0, #0xFF         //Offset pag lvl2.

      ADD R2, R2, R4          //Add flags to PADDR.
      ADD R3, R3, R0, LSL #2  //Fist pointer of table.
ciclo_paging_lvl2:
      STR R2, [R3], #4
      
      ADD R2, #0x1000         //Next phisical address
      SUBS R1, #1             //one less page left.
      BNE ciclo_paging_lvl2

      BX LR

.end

//MRC p15, 0, <Rt>, c2, c0, 2 //READ TTBCR -> CONTROL DE LOS TTBR0 {EAE[31], N[3-0]}
//MRC p15, 0, <Rt>, c2, c0, 0 //READ TTBR0 -> DIR DE INICIO DE TABLA + FLAGS {NOS[5], RGN[4-3], IMP[2], S[1], C[0]}

//MCR p15, 0, R0, c3, c0, 0   //READ DACR -> CONTROLA LOS DOMINIOS DE PAGINA
//MRC p15, 0, <Rt>, c1, c0, 0 //READ SCTRL -> HABILITACION GENERAL {AFE[29] MMU[0]}
