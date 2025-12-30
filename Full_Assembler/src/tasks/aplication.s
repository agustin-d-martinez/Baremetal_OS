/**************** VARIABLES GLOBALES ********************/
.global _app_start
/********************************************************/

/**************** VARIABLES EXTERNAS ********************/
/********************************************************/

.code 32
.section .text_kernel,"ax"@progbits
_app_start: 
      ADD R0, R0, #1
      ADD R1, R0, #1
      ADD R2, R0, #1
      .word 0xE7FFFFFF        //Pruebo el undefined exception

      //LDR R4,=0x70020006      //Pruebo un abort
      //BLX R4

      MOV R0, #50
      MOV R1, #1
      MOV R2, #40
      MOV R3, #0
      SVC 1                   //Pruebo el system exception

      MOV R0, #0
      MOV R1, #1
      MOV R2, #2
      MOV R3, #3
      MOV R4, #4
      MOV R5, #5
      MOV R6, #6
      MOV R7, #7
      MOV R8, #8
      MOV R9, #9
      MOV R10, #10
      MOV R11, #11
      MOV R12, #12

_task3:
      WFI
      B _task3
.end
