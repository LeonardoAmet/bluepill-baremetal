# Entendiendo `linker.ld`

El archivo `linker.ld` define cómo se distribuyen el código y los datos en la memoria del STM32F103C8T6.

El compilador traduce cada archivo fuente a objetos (`.o`), pero el linker es quien decide finalmente dónde queda cada sección dentro de Flash y RAM.

## Qué define este script

En este proyecto el linker script fija:

1. las regiones de memoria disponibles,
2. la ubicación de secciones como `.vectors`, `.text`, `.data` y `.bss`,
3. los símbolos que necesita `startup.c` para inicializar el sistema.

## Regiones de memoria

```ld
MEMORY {
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 64K
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}
```

Esto describe el mapa básico del microcontrolador:

- `FLASH`: donde vive el código y los datos iniciales,
- `RAM`: donde viven las variables en tiempo de ejecución, la pila y otras estructuras temporales.

Además suele definirse el stack inicial:

```ld
__reset_stack_pointer = ORIGIN(RAM) + LENGTH(RAM);
```

Ese valor apunta al final de la RAM, que es donde normalmente comienza la pila en Cortex-M.

## Secciones principales

### `.vectors`

```ld
.vectors : {
    *(.isr_vector);
} > FLASH
```

Contiene la tabla de vectores de interrupción. Debe ubicarse al comienzo de Flash para que el procesador pueda tomarla en el reset.

### `.text`

```ld
.text : {
    *(.text*)
} > FLASH
```

Incluye el código ejecutable y, según el proyecto, otras secciones relacionadas como constantes o tablas.

### `.data`

```ld
_sdata = .;
.data : {
    *(.data*)
} > RAM AT > FLASH
_edata = .;
```

`.data` contiene variables globales o estáticas con valor inicial.

Durante la ejecución viven en RAM, pero su valor inicial se almacena en Flash. Por eso `startup.c` debe copiarlas al arrancar.

La dirección de origen se obtiene con:

```ld
_load_address = LOADADDR(.data);
```

### `.bss`

```ld
_sbss = .;
.bss : {
    *(.bss*)
} > RAM
_ebss = .;
```

`.bss` contiene variables no inicializadas. No ocupa espacio útil en Flash para datos, pero sí reserva RAM. En el arranque debe completarse con ceros.

## El contador de ubicación `.`

El símbolo `.` representa la posición actual del linker dentro de la región de memoria activa. Se usa para marcar comienzos y finales de secciones, por ejemplo `_sdata`, `_edata`, `_sbss` y `_ebss`.

## Mapa conceptual de memoria

```text
FLASH
0x08000000  -> .vectors
              .text
              valores iniciales de .data
... 

RAM
0x20000000  -> .data
              .bss
              espacio libre
              stack
0x20005000  -> stack pointer inicial
```

## Relación con `startup.c`

El startup usa los símbolos del linker para:

- copiar `.data` desde Flash a RAM,
- limpiar `.bss`,
- cargar el valor inicial de la pila.

Por eso `linker.ld` y `startup.c` deben leerse juntos. Uno define el mapa; el otro usa ese mapa para inicializar la memoria.

## Por qué conviene entenderlo

Entender el linker script ayuda a:

- depurar errores de memoria,
- interpretar mapas de enlazado,
- adaptar el firmware a otras variantes del micro,
- saber qué ocurre realmente entre el código fuente y la memoria física del dispositivo.

## Lecturas relacionadas

- [startup.md](startup.md)
- [main.md](main.md)
- [toolchain.md](toolchain.md)
- [README.md](../README.md)
