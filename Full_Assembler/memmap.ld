/***********************************************************************************
    Definiciones necesarias: formato de salida, arquitectura y punto de entrada
***********************************************************************************/
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_start)

/***********************************************************************************
    Definiciones de simbolos necesarios
***********************************************************************************/
/* VMA */
_RST_VECTOR_INIT =  0x00000000;
_BOOTLOADER_INIT =  0x70010000;      /*Entry point de la placa*/

_TEXT_KERNEL =      0x70030000;
_TEXT_TASK =        0x70040000;

_STACK_INIT =       0x70060000;

_DATA_TASK =        0x700A0000;
_DATA_KERNEL_INIT = 0x81000000;

_BSS_TASK =         0x70100000;
_BSS_KERNEL_INIT =  0x82000000;

/* PHISIC ADDRESS */
__boot_PADDR__ =            _BOOTLOADER_INIT;
__reset_vector_PADDR__ =    _RST_VECTOR_INIT;

__text_kernel_PADDR__ =     _TEXT_KERNEL;
__task1_PADDR__ =           0x80010000;
__task2_PADDR__ =           0x80020000;

__stack_PADDR__ =           0x80100000;

__data_task1_PADDR__ =      0x80200000;
__data_task2_PADDR__ =      0x80210000;
__data_kernel_PADDR__ =     0x81000000;

__bss_task1_PADDR__ =       0x80300000;
__bss_task2_PADDR__ =       0x80310000;
__bss_kernel_PADDR__ =      _BSS_KERNEL_INIT; 


/* STACK SIZES */
_SYS_STACK_SIZE = 4K;
_IRQ_STACK_SIZE = 4k;
_FIQ_STACK_SIZE = 4k;
_SVC_STACK_SIZE = 4k;
_ABT_STACK_SIZE = 4k;
_UND_STACK_SIZE = 4k;

_TASK1_STACK_SIZE = 4k;
_TASK2_STACK_SIZE = 4k;

/* BSS SIZE */
_BSS_TASK1_SIZE = 128K;
_BSS_TASK2_SIZE = 128K;
_BSS_KERNEL_SIZE = 128K;

/***********************************************************************************
    Regiones del mapa de memoria
***********************************************************************************/
MEMORY
{
    DRAM (rx)  : ORIGIN = 0x00000000, LENGTH = 16M      /*Pertenece a la ROM, pero puede ser remapeado. Aca van las intrp.*/
    SDRAM (rwx) : ORIGIN = 0x70000000, LENGTH = 512M    /*CS0 y CS1. Memorias externas donde va el código*/
}
/***********************************************************************************
    Definición de las secciones
***********************************************************************************/
SECTIONS
{
    /*name [VMA DIR] : AT([LMA DIR])*/
    boot _BOOTLOADER_INIT : AT(_BOOTLOADER_INIT)       /*Inicio de mi codigo. Al amanecer aca, deberia coincidir su valor VMA y LMA*/
    {
        . = ALIGN(4);
        __boot_start__ = .;
        KEEP(*(boot*))
        __boot_end__ = .;
    }
    __boot_size__ = __boot_end__ - __boot_start__;
    __boot_LMA__ = LOADADDR(boot);

    .text_kernel _TEXT_KERNEL : AT(LOADADDR(boot) + SIZEOF(boot))
    {
        . = ALIGN(4);
        __text_kernel_start__ = .;
        *(.text_kernel*)
        __text_kernel_end__ = .;
    }
    __text_kernel_size__ = __text_kernel_end__ - __text_kernel_start__;
    __text_kernel_LMA__ = LOADADDR(.text_kernel);
    
    .task1 _TEXT_TASK : AT(LOADADDR(.text_kernel) + SIZEOF(.text_kernel))
    {
        . = ALIGN(4);
        __task1_start__ = .;
        *(.task1*)
        __task1_end__ = .;
    }
    __task1_size__ = __task1_end__ - __task1_start__;
    __task1_LMA__ = LOADADDR(.task1);

    .task2 _TEXT_TASK : AT(LOADADDR(.task1) + SIZEOF(.task1))
    {
        . = ALIGN(4);
        __task2_start__ = .;
        *(.task2*)
        __task2_end__ = .;
    }
    __task2_size__ = __task2_end__ - __task2_start__;
    __task2_LMA__ = LOADADDR(.task2);

    .stack _STACK_INIT (NOLOAD): 
    {
        __stack_start__ = .;
        . += _SVC_STACK_SIZE;
        . = ALIGN(4);
        __svc_stack_top__ = .;  /*0x70061000*/

        . += _SYS_STACK_SIZE;
        . = ALIGN(4);
		__sys_stack_top__ = .;

        . += _IRQ_STACK_SIZE;
        . = ALIGN(4);
        __irq_stack_top__ = .;

        . += _FIQ_STACK_SIZE;
        . = ALIGN(4);
        __fiq_stack_top__ = .;

        . += _ABT_STACK_SIZE;
        . = ALIGN(4);
        __abt_stack_top__ = .;

        . += _UND_STACK_SIZE;
        . = ALIGN(4);
        __und_stack_top__ = .;

        . += _TASK1_STACK_SIZE;
        . = ALIGN(4);
        __TASK1_stack_top__ = .;

        . += _TASK2_STACK_SIZE;
        . = ALIGN(4);
        __TASK2_stack_top__ = .;
        __stack_end__ = .;
    }
    __stack_size__ = __stack_end__ - __stack_start__;

    .data_task1 _DATA_TASK : AT(LOADADDR(.task2) + SIZEOF(.task2))
    {
        . = ALIGN(4);
        __data_task1_start__ = .;
        *(.data_task1*)
        __data_task1_end__ = .;
    }
    __data_task1_size__ = __data_task1_end__ - __data_task1_start__;
    __data_task1_LMA__ = LOADADDR(.data_task1);

    .data_task2 _DATA_TASK : AT(LOADADDR(.data_task1) + SIZEOF(.data_task1))
    {
        . = ALIGN(4);
        __data_task2_start__ = .;
        *(.data_task2*)
        __data_task2_end__ = .;
    }
    __data_task2_size__ = __data_task2_end__ - __data_task2_start__;
    __data_task2_LMA__ = LOADADDR(.data_task2);

    .data_kernel _DATA_KERNEL_INIT : AT(LOADADDR(.data_task2) + SIZEOF(.data_task2))
    {
        . = ALIGN(4);
        __data_kernel_start__ = .;
        *(.data_kernel*)
        __data_kernel_end__ = .;
    }
    __data_kernel_size__ =  __data_kernel_end__ - __data_kernel_start__;
    __data_kernel_LMA__ =   LOADADDR(.data_kernel);

    reset_vector _RST_VECTOR_INIT : AT(LOADADDR(.data_kernel) + SIZEOF(.data_kernel))
    {
        . = ALIGN(4);
        __reset_vector_start__ = .;
        KEEP(*(reset_vector*))
        __reset_vector_end__ = .;
    }
    __reset_vector_size__ =     __reset_vector_end__ - __reset_vector_start__;
    __reset_vector_LMA__ =      LOADADDR(reset_vector);

    .bss_task1 _BSS_TASK (NOLOAD): 
    {
        . = ALIGN(4);
        __bss_task1_start__ = .;
        . += _BSS_TASK1_SIZE;
        __bss_task1_end__ = .;
    }
    __bss_task1_size__ = _BSS_TASK1_SIZE;

    .bss_task2 _BSS_TASK (NOLOAD): 
    {
        . = ALIGN(4);
        __bss_task2_start__ = .;
        . += _BSS_TASK2_SIZE;
        __bss_task2_end__ = .;
    }
    __bss_task2_size__ = _BSS_TASK2_SIZE;

    .bss_kernel _BSS_KERNEL_INIT (NOLOAD): 
    {
        . = ALIGN(4);
        __bss_kernel_start__ = .;
        . += _BSS_KERNEL_SIZE;
        __bss_kernel_end__ = .;
    }
    __bss_kernel_size__ =   _BSS_KERNEL_SIZE;
}
