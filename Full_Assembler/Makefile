#####################################################################
# AUTHOR INFORMATION 												#
#####################################################################
AUTHOR ?= Agustin martinez
DATE ?= 25/04/25
VERSION ?= 2.5

# $^ es una variable automática que representa a una lista de todos los pre-requisitos de un objetivo
# $@ es una variable automática que representa el objetivo a "buildear"
# $< es una variable automática que representa el PRIMER pre-requisito del objetivo

SHELL := /bin/bash
MAKEFLAGS += --warn-undefined-variables

#####################################################################
# APP NAME - Nombre del ejecutable									#
#####################################################################
APP ?= ej7

#####################################################################
# DIRECTORY TREE, SOURCES, OBJECTS 									#
#####################################################################
CURRENT_DIR := $(shell pwd)
OBJ = obj
BIN = bin
INC = inc
SRC = src
LST = lst

MEMMAP_FILE = memmap.ld

# Encuentra todos los archivos .c y .s en los subdirectorios de src
SRCFILES = $(shell find $(SRC) -name '*.c' -o -name '*.s')
# Genera una lista de archivos .o correspondientes en el directorio obj
OBJFILES = $(patsubst $(SRC)/%, $(OBJ)/%, $(SRCFILES:.c=.o))
OBJFILES := $(patsubst $(SRC)/%, $(OBJ)/%, $(OBJFILES:.s=.o))

#####################################################################
# Varaibles GDBINIT 												#
#####################################################################
GDBINIT_LOCAL := .gdbinit
GDBINIT_GLOBAL_DIR := $(HOME)/.config/gdb
GDBINIT_GLOBAL := $(GDBINIT_GLOBAL_DIR)/gdbinit

BINFILE = $(APP).bin
TARGET = $(BIN)/$(BINFILE)
TARGET_ELF = $(OBJ)/$(APP).elf

#####################################################################
# COMPILER AND ARGUMENTS 											#
#####################################################################
#-------- Toolchain
CHAIN=arm-linux-gnueabihf
# Flags del compilador
CFLAGS=-std=gnu99 -Wall -mcpu=cortex-a8
# Flags del ensamblador
AFLAGS=--gdwarf-2
# Flags del linker
LDFLAGS=

#####################################################################
# Debugguer y Emulacion			 									#
#####################################################################
#placa a emular en la maquina virtual de QEMU. Otras placas posibles a emular descomentar la que se quiera usar:
# mcimx6ul-evk		vexpress-a15
# para ver el listado completo usar el comando: qemu-system-arm -M help | grep Cortex-A
# se puede usar cualquiera lo que cambia es el vector de reset en la emualcion. Cambiar el linker script acordemente
#------- Motor de maquina virtual a utilizar
VME=qemu-system-arm

#falgs para el QEMU 
BOARD=realview-pb-a8
PORT=1234
VMFLAGS= -M $(BOARD) -m 512M -no-reboot -nographic -monitor telnet:127.0.0.1:$(PORT),server,nowait
TCP_PORT=2159

#------ Depurador/ Debbuguer
CC=ddd
CCFLGS=--debugger

#####################################################################
# GIT         					 									#
#####################################################################
MSG_COMMIT ?= "Actualización desde Makefile"
REMOTE ?= origin
BRANCH ?= main

#####################################################################
# MAKE TARGETS					 									#
#####################################################################
# Phony targets
.PHONY: all clean rebuild run debug folder_tree help \
        git-init git-add git-commit git-push git-all \
        git-restore git-discard

# Regla principal
all: $(TARGET) $(GDBINIT_LOCAL)
	@echo "Compilación finalizada. Listo para ejecutar o depurar."

# Regla para generar el binario a partir del ELF
$(TARGET): $(TARGET_ELF)
	@echo ""
	@echo "Generando binario..."
	$(CHAIN)-objcopy -O binary $< $@
	@echo "Binario generado en $(TARGET)"

# Regla para enlazar el ejecutable
$(TARGET_ELF): $(OBJFILES)| $(BIN) $(LST)
	@echo ""
	@echo "Linkeando ... "
	$(CHAIN)-ld -T $(MEMMAP_FILE) $(LDFLAGS) $^ -o $@ -Map $(LST)/$(APP).map
	@echo "Linkeo finalizado!!"
	@echo ""
	@echo "Generando archivos de información: mapa de memoria y simbolos"
	readelf -a $@  > $(LST)/$(APP)_readelf.txt
	$(CHAIN)-objdump -D $@  > $(LST)/$(APP).lst

# Regla para compilar archivos .c a .o
$(OBJ)/%.o: $(SRC)/%.c | $(OBJ) $(LST)
	@echo ""
	mkdir -p $(dir $@)
	@echo "Compilando (C) $(notdir $<)..."
	$(CHAIN)-gcc $(CFLAGS) -g -c -O0 $< -o $@
	@echo "Ensamblado finalizado!!"

# Regla para ensamblar archivos .s a .o
$(OBJ)/%.o: $(SRC)/%.s | $(OBJ) $(LST)
	@echo ""
	@echo "Compilando (ASM) $(notdir $<)..."
	$(CHAIN)-as $(AFLAGS) $< -g -o $@ -a > $(LST)/$(basename $(notdir $<)).lst
	@echo "Compilado finalizado!!"

# Crea carpetas faltantes
$(OBJ) $(BIN) $(LST):
	mkdir -p $@


# Crea el archivo .gdbinit local y lo agrega al path seguro del gdb
$(GDBINIT_LOCAL):
	@echo "creando .gdbinit local..."
	echo "target remote localhost:$(TCP_PORT)" > $(GDBINIT_LOCAL)
	@echo ""
	@echo "Anadiendo .gdbinit al path seguro..."
	mkdir -p $(GDBINIT_GLOBAL_DIR)
	echo "add-auto-load-safe-path $(CURRENT_DIR)/$(GDBINIT_LOCAL)" > $(GDBINIT_GLOBAL)
	@echo ""

# Limpia los archivos generados
clean:
	rm -rf $(OBJ) $(BIN) $(LST) $(GDBINIT_LOCAL)

# Reconstruye el proyecto limpiando primero
rebuild: clean all

# Crea la estructura de directorios para empezar el desarrollo
folder_tree:
	mkdir -p $(SRC) $(INC)
	@echo "Estructura de directorios creada."

#Empieza a simular con qemu a la placa.
run:
	$(VME) $(VMFLAGS) -S -gdb tcp::$(TCP_PORT) -kernel $(TARGET)

#Abre el gdb. Este comando debe ejecutarse donde se encuentra el .gdbinit. 
debug:
	$(CC) $(CCFLGS) gdb-multiarch $(TARGET_ELF)

dist: clean
	tar czf $(APP)-$(VERSION).tar.gz $(SRC) $(INC) Makefile README.md


# Inicializa un nuevo repositorio git
git-init:
	git init
	@echo "Repositorio Git inicializado."

# Añade todos los cambios al staging area
git-add:
	git add .
	@echo "Todos los cambios añadidos al área de staging."

# Hace commit con el mensaje definido en MSG
git-commit:
	git commit -m $(MSG_COMMIT)
	@echo "Commit realizado con mensaje: $(MSG_COMMIT)"

# Hace push al remoto por defecto (origin) y rama por defecto (master/main)
git-push:
	git push $(REMOTE) $(BRANCH)
	@echo "Cambios enviados al remoto '$(REMOTE)' en la rama '$(BRANCH)'."

# Restaura un archivo eliminado del último commit
git-restore:
	git restore .

# Descarta todos los cambios
git-discard:
	git restore :/

# Combina add, commit, push 
git-all: git-add git-commit git-push
	@echo "Git: add → commit → push completado."

# Objetivo de ayuda que lista los comandos disponibles y su descripción
help:
	@echo "-------------------------------------------------"
	@echo "         Guía de uso del Makefile               "
	@echo "-------------------------------------------------"
	@echo "all         : Compila y genera el ejecutable."
	@echo "clean       : Elimina archivos y directorios generados."
	@echo "rebuild     : Limpia y recompila todo el proyecto."
	@echo "run         : Inicia la emulación con QEMU."
	@echo "debug       : Abre el depurador (GDB) con ddd."
	@echo "folder_tree : Crea la estructura de directorios (src, inc)."
	@echo "dist 	   : COmprime los archivos fuentes en un .zip/.tar."
	@echo "git-init    : Inicializa un repositorio Git local."
	@echo "git-add     : Añade todos los cambios al área de staging."
	@echo "git-commit  : Hace commit con mensaje (MSG)."
	@echo "git-push    : Envía los commits al remoto."
	@echo "git-all     : add → commit → push en un solo paso."
	@echo "git-restore : Restaura archivos borrados al último commit."
	@echo "git-discard : Descarta cambios locales no confirmados."
	@echo "help        : Muestra esta ayuda."
	@echo "-------------------------------------------------"
	@echo "Para iniciar se deben tener todos los fuentes y  "
	@echo "los headers en sus carpetas SRC y INC."
	@echo "-------------------------------------------------"

