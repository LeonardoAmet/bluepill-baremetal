# Análisis de `main.c`

Este archivo muestra un ejemplo mínimo de firmware bare-metal para la Blue Pill. No usa HAL ni CMSIS como capa de acceso a periféricos: todo se hace escribiendo y leyendo registros.

## Qué hace el programa

- habilita el reloj del puerto GPIOC,
- configura el pin PC13 como salida push-pull,
- alterna el estado del LED integrado con un retardo por software.

## Registros usados

```c
#define RCC_APB2ENR     (*((volatile uint32_t*)0x40021018U))
#define GPIOC_BASE      (0x40011000U)
#define GPIOC_CRH       (*((volatile uint32_t*)(GPIOC_BASE + 0x4U)))
#define GPIOC_ODR       (*((volatile uint32_t*)(GPIOC_BASE + 0xCU)))
```

Estos macros representan direcciones de registros mapeados en memoria.

- `RCC_APB2ENR`: controla la habilitación de reloj de periféricos en APB2.
- `GPIOC_CRH`: configura los pines PC8 a PC15.
- `GPIOC_ODR`: permite escribir el valor lógico del pin.

La referencia completa está en el manual RM0008 de STM32F1.

## Por qué aparece `volatile`

Cuando se accede a registros de hardware, el compilador no puede asumir que el valor permanece estable ni que una escritura es opcional. Por eso los punteros se declaran como `volatile`.

Sin `volatile`, el compilador podría:

- eliminar lecturas que considera redundantes,
- reordenar accesos,
- optimizar escrituras que en realidad son necesarias.

## Habilitación del reloj de GPIOC

```c
RCC_APB2ENR |= (1U << 4);
```

Ese bit corresponde a `IOPCEN`. Sin habilitar el reloj, el acceso a GPIOC no funciona aunque los registros existan.

## Configuración de PC13

```c
GPIOC_CRH &= ~(0xF << 20);
GPIOC_CRH |=  (0x2 << 20);
```

Cada pin usa 4 bits de configuración. En PC13:

- `CNF13 = 00`: salida push-pull,
- `MODE13 = 10`: salida a 2 MHz.

## Bucle principal

```c
while (1) {
    GPIOC_ODR |=  (1U << 13);
    for (int i = 0; i < 500000; i++);

    GPIOC_ODR &= ~(1U << 13);
    for (int i = 0; i < 500000; i++);
}
```

En muchas Blue Pill el LED de PC13 es activo en bajo. Eso significa:

- `PC13 = 1` -> LED apagado,
- `PC13 = 0` -> LED encendido.

El retardo es un busy wait. Sirve para un ejemplo inicial, pero no es preciso ni escalable.

## Por qué este ejemplo importa

Este tipo de programa permite entender:

- cómo se habilita un periférico,
- cómo se configura un pin sin librerías externas,
- cómo se traduce una idea simple en operaciones sobre registros,
- qué abstraen después CMSIS, libopencm3 o HAL.

## Lecturas relacionadas

- [startup.md](startup.md)
- [linker.md](linker.md)
- [toolchain.md](toolchain.md)
- [README.md](../README.md)
