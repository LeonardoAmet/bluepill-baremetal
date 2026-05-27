# Entendiendo `startup.c`

En un proyecto bare-metal no hay sistema operativo ni runtime que prepare el entorno antes de ejecutar `main()`. Ese trabajo inicial lo hace el código de arranque, normalmente ubicado en `startup.c` o en un archivo equivalente.

## Qué resuelve el archivo de arranque

Su responsabilidad es dejar al microcontrolador en un estado mínimo y consistente para que el programa principal pueda correr.

En este caso incluye:

1. la tabla de vectores,
2. el `Reset_Handler`,
3. handlers por defecto para excepciones e interrupciones no implementadas.

## Tabla de vectores

```c
__attribute__((section(".isr_vector")))
void (*const vector_table[])(void) = {
    (void (*)(void))(&__reset_stack_pointer),
    Reset_Handler,
    NMI_Handler,
    HardFault_Handler,
    ...
};
```

La tabla de vectores le indica a la CPU:

- cuál es el valor inicial del stack pointer,
- qué función ejecutar después de un reset,
- qué ISR corresponde a cada excepción o interrupción.

El linker ubica esta tabla al comienzo de la memoria Flash.

## `Reset_Handler`

Es el punto de entrada real del programa después de un reset.

Sus tareas típicas son:

- copiar `.data` desde Flash a RAM,
- inicializar `.bss` con ceros,
- invocar `main()`.

Ejemplo simplificado:

```c
void Reset_Handler(void) {
    uint32_t *src = &_load_address;
    for (uint32_t *dest = &_sdata; dest < &_edata;) {
        *dest++ = *src++;
    }

    for (uint32_t *dest = &_sbss; dest < &_ebss;) {
        *dest++ = 0;
    }

    main();

    while (1);
}
```

Si `main()` retorna, el código entra en un bucle infinito. En firmware embebido eso suele considerarse una condición inválida o al menos no prevista.

## Handlers por defecto

Cuando una interrupción no tiene implementación propia, normalmente se redirige a un handler por defecto:

```c
void Default_Handler(void) {
    while (1);
}
```

Eso permite detectar fallos tempranamente durante debug. Si el micro entra ahí, es señal de que ocurrió una excepción no atendida o de que falta una ISR.

## Relación con el linker script

`startup.c` depende de símbolos definidos en `linker.ld`, por ejemplo:

- `__reset_stack_pointer`
- `_sdata`
- `_edata`
- `_sbss`
- `_ebss`
- `_load_address`

Sin esos símbolos, el startup no sabe:

- dónde empieza la RAM útil,
- dónde están las secciones a copiar,
- ni cuál debe ser el stack inicial.

## Por qué conviene entenderlo

Entender el startup ayuda a:

- depurar errores tempranos de arranque,
- integrar bibliotecas o RTOS con más criterio,
- adaptar el proyecto a otros micros o mapas de memoria,
- entender qué ocurre antes de que `main()` siquiera exista como contexto de ejecución.

## Lecturas relacionadas

- [linker.md](linker.md)
- [main.md](main.md)
- [toolchain.md](toolchain.md)
- [README.md](../README.md)
