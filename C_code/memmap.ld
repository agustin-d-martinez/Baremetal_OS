/*
	Definiciones necesarias: formato de salida, arquitectura y punto de entrada
*/

OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_reset_vector)

/*
	Definiciones de simbolos necesarios
*/

/* Tamaño de los stacks del kernel*/

IRQ_STACK_SIZE = 128;
FIQ_STACK_SIZE = 128;
SVC_STACK_SIZE = 128;
ABT_STACK_SIZE = 128;
UND_STACK_SIZE = 128;
SYS_STACK_SIZE = 4K;

/* Tamaño de stack a las tareas */

/* IDLE */

IRQ_IDLE_STACK_SIZE = 128;
SVC_IDLE_STACK_SIZE = 128;
SYS_IDLE_STACK_SIZE = 128;

/* TASK 1 */

IRQ_TASK1_STACK_SIZE = 128;
SVC_TASK1_STACK_SIZE = 128;
SYS_TASK1_STACK_SIZE = 128;

/* TASK 2 */

IRQ_TASK2_STACK_SIZE = 128;
SVC_TASK2_STACK_SIZE = 128;
SYS_TASK2_STACK_SIZE = 128;

/* TASK 3 */

IRQ_TASK3_STACK_SIZE = 128;
SVC_TASK3_STACK_SIZE = 128;
SYS_TASK3_STACK_SIZE = 128;

/* ---------- Physical ---------- */

_PUBLIC_RAM_INIT = 0x70010000;
_PUBLIC_STACK_INIT = 0x70020000;

/* Tareas */
_IDLE_TXT_PHY         	 = 0x70034000;
_TASK_1_TXT_PHY            = 0x80750000;
_TASK_2_TXT_PHY            = 0x80740000;
_TASK_3_TXT_PHY            = 0x80730000;
_USER_DATA_GLOBAL_PHY      = 0x80720000;
_TASK_1_READ_AREA_PHY 	   = 0x80000000;

/* Tablas de paginación */
_TTBR0_IDLE           	= 0x70080000;
_TTBR0_TASK_1           = 0x70090000;
_TTBR0_TASK_2           = 0x700A0000;
_TTBR0_TASK_3           = 0x700B0000;

/* ------------------ VMA ------------------ */

/* Tareas */
_IDLE_TXT_VMA         	   = 0x70034000;
_TASK_1_TXT_VMA            = 0x70f50000;
_TASK_2_TXT_VMA            = 0x70f40000;
_TASK_3_TXT_VMA            = 0x70f30000;
_USER_DATA_GLOBAL_VMA      = 0x70035000;
_TASK_1_READ_AREA_VMA	   = 0x70A00000;

/*
	Definicion del mapa de memoria
*/

MEMORY
{
	public_ram          : org = _PUBLIC_RAM_INIT, len = 0x10000 	  /* va de 0x70010000 a 0x7001FFFF */
	public_stack        : org = _PUBLIC_STACK_INIT, len = 0x10000 	  /* va de 0x70020000 a 0x7002FFFF */

	idle_txt_vma      : org = _IDLE_TXT_VMA,    len = 0x1000
    idle_txt_phy      : org = _IDLE_TXT_PHY,    len = 0x1000

	task_1_txt_vma    : org = _TASK_1_TXT_VMA,  len = 0x1000
    task_1_txt_phy    : org = _TASK_1_TXT_PHY,  len = 0x1000

    task_2_txt_vma    : org = _TASK_2_TXT_VMA,  len = 0x1000
    task_2_txt_phy    : org = _TASK_2_TXT_PHY,  len = 0x1000

	task_3_txt_vma    : org = _TASK_3_TXT_VMA,  len = 0x1000
    task_3_txt_phy    : org = _TASK_3_TXT_PHY,  len = 0x1000
	
	user_data_global_vma    : org = _USER_DATA_GLOBAL_VMA,  len = 0x1000
    user_data_global_phy    : org = _USER_DATA_GLOBAL_PHY,  len = 0x1000
}

/*
	Definicion de las secciones
*/

SECTIONS
{
	. = _PUBLIC_RAM_INIT;
	/*-----kernel-----*/
	.text : {
		*(.text_reset_vector)
		*(.text*)
		} > public_ram
	
	.data : { 
		*(.data_global)
		*(.data*)
		} > public_ram

	.bss : {
		. = ALIGN(4);
		__bss_start__ = .;
		*(.bss*)
		__bss_end__ = .;
		} > public_ram
	_IDLE_TXT_LMA = .;
	
	.idle_text : AT (_IDLE_TXT_LMA){
		*(.idle*)
		. = ALIGN(4); 
		} > idle_txt_vma
	
	__idle_size__ = SIZEOF(.idle_text);

	_TASK_1_TXT_LMA = _IDLE_TXT_LMA + __idle_size__;
	.task1_text : AT (_TASK_1_TXT_LMA){
		*(.task1*)
		. = ALIGN(4); 
		} > task_1_txt_vma

	__task1_size__ = SIZEOF(.task1_text);

	_TASK_2_TXT_LMA = _TASK_1_TXT_LMA + __task1_size__;
	
	.task2_text : AT (_TASK_2_TXT_LMA){
		*(.task2*)
		. = ALIGN(4); 
		} > task_2_txt_vma
	
	__task2_size__ = SIZEOF(.task2_text);

	_TASK_3_TXT_LMA = _TASK_2_TXT_LMA + __task2_size__;
	.task3_text : AT (_TASK_3_TXT_LMA){
		*(.task3*)
		. = ALIGN(4); 
		} > task_3_txt_vma
	
	__task3_size__ = SIZEOF(.task3_text);

	_USER_DATA_GLOBAL_LMA = _TASK_3_TXT_LMA + __task3_size__;
	.user_global_data : AT (_USER_DATA_GLOBAL_LMA){
		*(.user_data_global*)
		. = ALIGN(4); 
		} > user_data_global_vma

	. = _PUBLIC_STACK_INIT;
	.stack : {
		__stack_start__ = .;
		. += IRQ_STACK_SIZE;
		. = ALIGN(4);
		__irq_stack_top__ = .; 

		. += FIQ_STACK_SIZE;
		. = ALIGN(4);
		__fiq_stack_top__ = .;

		. += SVC_STACK_SIZE;
		. = ALIGN(4);
		__svc_stack_top__ = .;

		. += ABT_STACK_SIZE;
		. = ALIGN(4);
		__abt_stack_top__ = .;

		. += UND_STACK_SIZE;
		. = ALIGN(4);
		__und_stack_top__ = .;

		. += SYS_STACK_SIZE;
		. = ALIGN(4);
		__sys_stack_top__ = .;

		. = ALIGN(0x1000); /* Align to 0x1000 */

		. += IRQ_IDLE_STACK_SIZE;
		. = ALIGN(4);
		__irq_idle_stack_top__ = .;

		. += SVC_IDLE_STACK_SIZE;
		. = ALIGN(4);
		__svc_idle_stack_top__ = .;

		. += SYS_IDLE_STACK_SIZE;
		. = ALIGN(4);
		__sys_idle_stack_top__ = .;

		. = ALIGN(0x1000); /* Align to 0x1000 */

		. += IRQ_TASK1_STACK_SIZE;
		. = ALIGN(4);
		__irq_task1_stack_top__ = .;

		. += SVC_TASK1_STACK_SIZE;
		. = ALIGN(4);
		__svc_task1_stack_top__ = .;

		. += SYS_TASK1_STACK_SIZE;
		. = ALIGN(4);
		__sys_task1_stack_top__ = .;

		. = ALIGN(0x1000); /* Align to 0x1000 */

		. += IRQ_TASK2_STACK_SIZE;
		. = ALIGN(4);
		__irq_task2_stack_top__ = .;

		. += SVC_TASK2_STACK_SIZE;
		. = ALIGN(4);
		__svc_task2_stack_top__ = .;

		. += SYS_TASK2_STACK_SIZE;
		. = ALIGN(4);
		__sys_task2_stack_top__ = .;

		. = ALIGN(0x1000); /* Align to 0x1000 */

		. += IRQ_TASK3_STACK_SIZE;
		. = ALIGN(4);
		__irq_task3_stack_top__ = .;

		. += SVC_TASK3_STACK_SIZE;
		. = ALIGN(4);
		__svc_task3_stack_top__ = .;

		. += SYS_TASK3_STACK_SIZE;
		. = ALIGN(4);
		__sys_task3_stack_top__ = .;

	} > public_stack
}
