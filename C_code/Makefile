#####################################################################
# AUTHOR INFORMATION 												#
#####################################################################
# AUTHOR: Agustin martinez
# DATE: 20/07/24
# VERSION: 2.0

# $^ es una variable automática que representa a una lista de todos los pre-requisitos de un objetivo
# $@ es una variable automática que representa el objetivo a "buildear"
# $< es una variable automática que representa el PRIMER pre-requisito del objetivo


#####################################################################
# APP NAME 															#
#####################################################################
# Nombre del ejecutable
BINFILE = bios

#####################################################################
# DIRECTORY TREE, SOURCES, OBJECTS 									#
#####################################################################
CURRENT_LOCATION = $(shell pwd)
INCDIR = inc
SRCDIR = src
OBJDIR = obj
BINDIR = bin
LSTDIR = lst

# Encuentra todos los archivos .c y .s en los subdirectorios de src
SRCFILES = $(shell find $(SRCDIR) -name '*.c' -o -name '*.s')
# Genera una lista de archivos .o correspondientes en el directorio obj
OBJFILES = $(patsubst $(SRCDIR)/%, $(OBJDIR)/%, $(SRCFILES:.c=.o))
OBJFILES := $(patsubst $(SRCDIR)/%, $(OBJDIR)/%, $(OBJFILES:.s=.o))

TARGET = $(BINDIR)/$(BINFILE)
TARGET_ELF = $(TARGET).elf

#####################################################################
# Debugguer y Emulacion			 									#
#####################################################################
#placa a emular en la maquina virtual de QEMU
BOARD=realview-pb-a8

#otras placas posibles a emular descomentar la que se quiera usar:
#BOARD=mcimx6ul-evk
#BOARD=vexpress-a15
# para ver el listado completo usar el comando:
# qemu-system-arm -M help | grep Cortex-A
# se puede usar cualquiera lo que cambia es el vector de reset en la emualcion
# tener en cuenta esto para modificar el linker script acorde

#####################################################################
# COMPILER AND ARGUMENTS 											#
#####################################################################
# Toolchain
CHAIN=arm-none-eabi
# Flags del compilador
CFLAGS=-std=gnu99 -Wall -mfpu=neon -mhard-float -mcpu=cortex-a8 -DCPU_A8
# Flags ????
AFLAGS=-mfpu=neon
# Flags del linker
LDFLAGS =

PORT=12345
#falgs para el QEMU
VMFLAGS= -M $(BOARD) -m 512M -no-reboot -nographic -monitor telnet:127.0.0.1:$(PORT),server,nowait
# motor de maquina virtual a utilizar
VME=qemu-system-arm

CC=ddd
CCFLGS=--debugger

#####################################################################
# MAKE TARGETS					 									#
#####################################################################
# Regla principal
all: $(TARGET)

# Regla para generar el binario a partir del ELF
$(TARGET): $(TARGET_ELF)
	$(CHAIN)-objcopy -O binary $< $@

# Regla para enlazar el ejecutable
$(TARGET_ELF): $(OBJFILES)
	@echo "Linkeando ... "
	mkdir -p $(BINDIR)
	mkdir -p $(LSTDIR)
	$(CHAIN)-ld -T memmap.ld $(LDFLAGS) -o $@ $^ -Map $(LSTDIR)/$(BINFILE).map
	@echo "Linkeo finalizado!!"
	@echo ""
	@echo "Generando archivos de información: mapa de memoria y simbolos"
	readelf -a $@  > $(LSTDIR)/$(BINFILE)_readelf.txt
	$(CHAIN)-objdump -D $@  > $(LSTDIR)/$(BINFILE).lst

# Regla para compilar archivos .c a .o
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@echo ""
	mkdir -p $(dir $@)
	mkdir -p $(LSTDIR)
	@echo "Ensamblando $(notdir $<)..."
	$(CHAIN)-gcc $(CFLAGS) -g -c -o $@ $<

# Regla para ensamblar archivos .s a .o
$(OBJDIR)/%.o: $(SRCDIR)/%.s
	@echo ""
	mkdir -p $(dir $@)
	mkdir -p $(LSTDIR)
	@echo "Compilando $(notdir $<)..."
	$(CHAIN)-as $(AFLAGS) -o $@ $< -a > $(LSTDIR)/$(basename $(notdir $<)).lst

# Limpia los archivos generados
clean:
	rm -rf $(OBJDIR) $(BINDIR) $(LSTDIR)

#Empieza a simular con qemu a la placa.
run:
# Estos echo generan el .gdbinit en la posicion actual.
#	echo "add-auto-load-safe-path $(shell pwd)" > $(HOME)/$(TEXT_FILE)
#	echo "set architecture arm\ntarget remote localhost:2159" > $(shell pwd)/$(TEXT_FILE)
	
# Estos echo generan el .gdbinit en "Documentos". Si ya los tenes creados, es innecesario. Siempre ponen lo mismo
#	echo "add-auto-load-safe-path $(HOME)/Documentos" > $(HOME)/$(TEXT_FILE)
#	echo "set architecture arm\ntarget remote localhost:2159" > $(HOME)/Documentos/$(TEXT_FILE)
	$(VME) $(VMFLAGS) -kernel $(TARGET) -S -gdb tcp::2159

#Abre el gdb. Este comando debe ejecutarse donde se encuentra el .gdbinit. 
debug:
# Este comando ejecuta el debugger desde documentos
	$(shell cd $(HOME)/Facultad/TD3 && $(CC) $(CCFLGS) gdb-multiarch $(CURRENT_LOCATION)/$(TARGET_ELF))
# ESte comando ejecuta el debugger desde mi posicion actual
#	$(CC) $(CCFLGS) gdb-multiarch $(OBJ_DIR)/$(APP).elf

rebuild: clean all


# Phony targets
.PHONY: all clean rebuild run debug
