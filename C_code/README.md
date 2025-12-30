# Implementación alternativa del sistema operativo

Este directorio contiene una **implementación alternativa** del sistema operativo bare-metal incluido en el repositorio principal.

El objetivo general del sistema es el mismo, pero se adoptan **decisiones de diseño diferentes** respecto a la implementación principal.

---

## Diferencias principales respecto a la implementación base

- **Uso intensivo de C**  
  Se prioriza el uso de lenguaje C en la mayor parte del sistema, reduciendo el código en Assembly al mínimo indispensable.

- **Espacios de direcciones virtuales diferenciados**  
  Cada tarea se ejecuta en una **VMA distinta**, en lugar de compartir una base común de direcciones virtuales.

- **Paginación con granularidad fija**  
  El sistema utiliza páginas de tamaño fijo de **4 KB**, asignando como máximo una página por sección.

- **Las tareas se ejecutan en modo usuario**
  Como en un SO real, las tareas no presentan privilegios. Cualquier acceso a memoria privilegiado debe realizarse mediante una System Call del SO. En este caso particular, las mismas se ejecutan con assembly inline:
  ```C
  asm volatile(
        "SVC #0x0\n"           // Trigger SVC 0 (read)
        "MOV %0, r0\n": "=r"(secret_kernel_value));       // Capture return value from r0 into result

  ```
  
---
