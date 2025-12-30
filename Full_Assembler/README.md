# Implementación principal del sistema operativo

Este directorio contiene la **implementación principal** del sistema operativo bare-metal.

---

## Diferencias principales respecto a la implementación alternativa

- **Uso puro de Assembly**  
  Se realizó en su totalidad en Assembly. Se reconoce que no es necesario y puede ser más flexible un código en C.

- **Espacios de direcciones virtuales**  
  Todas las tareas poseen la **misma VMA**. Esto se condice con sistemas operativos reales donde cada aplicación inicia en el mismo lugar (virtual). La implementación alternativa presindió de dicho feature (aunque podría implementarse ajustando los valores en el memmap.ld).

- **Paginación genérica**  
  El sistema utiliza **n** páginas de tamaño fijo de **4 KB** para paginar. Permite secciones de cualquier tamaño (siempre y cuando todas presenten la misma paginación de nivel 1).

- **Las tareas no se ejecutan en modo usuario**
  Las tareas fueron dejadas en modo privilegiado. Un SO real debe tenerlas en modo usuario por seguridad (impidiendo cualquier acceso a secciones paginadas que posean privilegios). Para modificarlo se deberían cambiar los flags de paginación (para eliminar requisitos de privilegios en las tareas) y realizar llamados a System Call siempre que se desea acceder fuera de esas páginas.
  
---
