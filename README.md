# Baremetal_OS

Este repositorio contiene la implementación de un **sistema operativo bare-metal**, desarrollado desde cero en C y Assembly, orientado a arquitecturas **ARMv7-A**.

El sistema se ejecuta sobre una plataforma **Cortex-A8**, simulada mediante emulación, y cubre los componentes fundamentales de un sistema operativo moderno: boot, manejo de memoria, interrupciones, multitarea y scheduling.

---

## Funcionamiento general

El sistema sigue el flujo clásico de un SO bare-metal:

1. Arranque desde una dirección definida por el fabricante
2. Reubicación del código en memoria
3. Inicialización de la MMU y memoria virtual
4. Configuración de stacks e interrupciones
5. Inicialización del kernel y scheduler
6. Ejecución de tareas en modo multitarea preemptive

---

## Mapa de memoria y Linker Script

### `memmap.ld`

El archivo `memmap.ld` es un **Linker Script**, encargado de definir:
- La disposición de memoria
- Las secciones del programa
- Las direcciones de carga y ejecución
- El control de tamaños y alineaciones

En el sistema se utilizan tres tipos de direcciones:

### Tipos de direcciones de memoria

- **VMA (Virtual Memory Address)**  
  Dirección virtual utilizada durante la ejecución normal del sistema y de las aplicaciones.  
  Todas las tareas se ejecutan en direcciones virtuales una vez habilitada la MMU.

- **PMA (Physical Memory Address)**  
  Dirección física real en memoria RAM.  
  Es la dirección que utiliza el hardware antes de la traducción por la MMU.

- **LMA (Load Memory Address)**  
  Dirección desde donde el código es cargado inicialmente (Flash o ROM).  
  Durante el arranque, el código es copiado desde la LMA a su PMA correspondiente.

La traducción de direcciones VMA → PMA se realiza mediante la **MMU** del Cortex-A8.

---

### Secciones de memoria

Las secciones estándar necesarias para el correcto funcionamiento del código C son:

- `.text` : Código ejecutable
- `.data` : Variables globales inicializadas
- `.bss`  : Variables globales no inicializadas
- `.stack`: Área de stack

---

### Sintaxis general del Linker Script

```ld
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(entry_name)

MEMORY {
	name (attr) : ORIGIN = val, LENGTH = val
	name (attr) : ORIGIN = val, LENGTH = val
	...
}

SECTIONS {
	.output_section_name vma_addr (attr): AT(lma_addr) {
		. = ALIGN(4);
		__start_var__ = .;
		*(.section_name)
		__end_var__ = .;
	}
	...
}
```

Para más información consultar la
**[Documentación oficial de GNU ld](https://sourceware.org/binutils/docs/ld.html)**.

---

## Proceso de Boot

Al iniciar la placa, el procesador comienza la ejecución desde un **entry point fijo**, definido por el fabricante (0x70010000 en este caso).

El proceso de arranque realiza los siguientes pasos:

1. Copia del código desde la **LMA** hacia su **PMA**.

   El código de arranque cumple la condición:

   ```
   LMA = PMA = VMA
   ```

   * Se instalan los **vectores de interrupción** en la dirección requerida por la arquitectura (típicamente dirección 0), utilizando instrucciones de salto hacia los handlers reales (`reset_vectors`).

2. Creación de las tablas de paginación y habilitación de la **MMU**.

   A partir de este punto, el sistema opera exclusivamente con direcciones virtuales.

3. Inicialización de los stacks.

   Se configuran los stack pointers para todos los modos de ejecución del procesador.

   > A partir de este punto es posible ejecutar código C.

4. Inicialización de los **PCB (Process Control Blocks)**.

   Estructuras necesarias para el cambio de contexto y multitarea.

5. Inicialización del **GIC** y del **Timer**.

   Permiten implementar scheduling preemptive basado en interrupciones de timer.

6. Habilitación global de interrupciones.

7. Salto a la primera tarea del sistema.

---

## Manejo de interrupciones

Cada tipo de interrupción posee su **handler dedicado**, el cual debe:

* Guardar el contexto previo
* Ejecutar la rutina correspondiente
* Restaurar el contexto antes de retornar

Debido al pipeline del procesador ARM, se realiza una corrección del PC antes de regresar de la interrupción.

Handlers implementados:

* **UNDEFINED**: Instrucción no definida.
* **SVC**: System Calls del sistema operativo.
* **Prefetch Abort**: Error durante el prefetch de instrucciones.
* **Data Abort**: Error durante acceso a datos.
* **IRQ**: Interrupciones de periféricos (scheduler).
* **FIQ**: Interrupciones rápidas de alta prioridad.

---

## Scheduler

El sistema implementa un **scheduler preemptive round-robin**.

Características:

* Cada tarea posee su propio **PCB**
* Cada tarea tiene su **tabla de paginación**
* Todas las aplicaciones pueden comenzar en la misma VMA.
* El cambio de tarea implica:

  * Guardado del contexto
  * Cambio de espacio de direcciones
  * Actualización del stack y registros

---

## Requisitos

* Toolchain ARM compatible con ARMv7-A.
* Emulador o simulador de Cortex-A8.
* `gdb` para depuración.

> El sistema fue probado utilizando **DDD + GDB** como entorno de depuración.

---

## Estructura del proyecto

```
proy_name/
├── src/
│   ├── board/
│   ├── core/
│   │   ├── startup.s
│   │   └── reset_vector.s
│   ├── handlers/
│   ├── kernel/
│   ├── scheduler/
│   └── task/
├── .gdbinit
├── Makefile
└── README.md
```

---

## Instalación de herramientas de depuración

Para compilar, ejecutar y depurar el sistema operativo se utilizan **GDB** y **DDD**.  
Estas herramientas no suelen venir instaladas por defecto en la mayoría de las distribuciones Linux.

### Instalación en Debian / Ubuntu

Actualizar la lista de paquetes:

```bash
sudo apt update
```

Instalar GDB:

```bash
sudo apt install gdb
```

Instalar DDD (Data Display Debugger):

```bash
sudo apt install ddd
```

En caso de depurar binarios ARM desde una arquitectura x86, puede ser necesario instalar:

```bash
sudo apt install gdb-multiarch
```

---

### Verificación de la instalación

Comprobar que GDB está correctamente instalado:

```bash
gdb --version
```

Comprobar que DDD está disponible:

```bash
ddd --version
```


### Notas

* **GDB** es la herramienta principal de depuración y es requerida para la ejecución del sistema.
* **DDD** actúa como interfaz gráfica sobre GDB y es opcional, pero facilita el seguimiento del flujo de ejecución.
* La configuración inicial de GDB se encuentra en el archivo `.gdbinit` incluido en el repositorio.

---

## Cómo ejecutar

1. Compilación del sistema:

```bash
make
```

El proceso de compilación genera la imagen del sistema operativo según lo definido en el `Makefile` y el `memmap.ld`.

2. Ejecución en entorno de simulación:

El sistema está diseñado para ejecutarse sobre una plataforma **Cortex-A8 simulada**.
La ejecución se realiza utilizando un emulador compatible con ARMv7-A y soporte de depuración remota.

En nuestro caso, utilizando el programa DDD y GDB para ejecutar y depurar, se debe escribir en la terminal:

```bash
make run
```

Este comando comienza a simular la placa con GDB. 

En otra terminal (que se encuentre en el mismo directorio que la anterior) se debe ejecutar:

```bash
make debug
```

Esto abrirá **DDD** y podremos simular la placa.

> En caso de querer utilizar otros compiladores o aplicaciones de debug, ver el makefile.

---

## Convenciones de desarrollo

* El código en **C** se ejecuta únicamente después de la inicialización completa de los stacks. No es capricho, **C** no puede funcionar sin stacks correctamente colocados.
* Todo acceso directo a hardware y configuración específica de la plataforma se concentra en el directorio `board/`.
* Cada tarea posee su propio contexto de ejecución y tabla de paginación.
* El cambio de contexto y la gestión de interrupciones se realizan exclusivamente en modo privilegiado.

---

## Por dónde empezar a leer el código

1. `memmap.ld` – mapa de memoria
2. `startup.s` – secuencia de arranque
3. `reset_vector.s` – interrupciones
4. `kernel/` – inicialización del sistema
5. `scheduler/` – cambio de tareas

> Opcional: Ver el Makefile. Muchos comandos ya se encuentran automatizados.


## Implementaciones incluidas

El repositorio contiene dos implementaciones del sistema operativo:

- Una implementación desarrollada por el autor de este repositorio (Full_Assembler).
- Una implementación alternativa desarrollada por un colaborador, ubicada en un directorio separado (C_code).

Ambas implementaciones comparten los mismos objetivos generales, pero difieren en decisiones de diseño y criterios de implementación.  
Cada directorio incluye su propia documentación con los detalles específicos.

---

## Autor

Agustín Martínez

---

## Licencia

Uso libre con fines educativos.

---

