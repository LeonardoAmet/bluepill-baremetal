# bluepill-baremetal

Proyecto mínimo para programar la Blue Pill (STM32F103C8T6) en bare-metal.

El objetivo de este repositorio es mostrar el camino más directo posible entre:

- el código fuente en C,
- el mapa de memoria del microcontrolador,
- el arranque del sistema,
- y el binario final que se flashea en la placa.

No usa HAL ni otras capas de abstracción. El acceso al hardware se hace por registros.

> El entorno fue probado en WSL2 con Ubuntu, pero también puede usarse en Linux nativo si están instaladas las herramientas necesarias.

## Estructura del proyecto

```text
bluepill-baremetal/
├── src/               # Código fuente en C
├── bin/               # Binarios generados (.elf, .bin, .map)
├── obj/               # Archivos objeto intermedios
├── docs/              # Documentación técnica
│   ├── main.md
│   ├── startup.md
│   ├── linker.md
│   └── toolchain.md
├── linker.ld          # Script de linker
├── Makefile           # Reglas de compilación y flashing
└── README.md
```

## Requisitos

- [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) o Linux nativo
- `gcc-arm-none-eabi`
- `openocd`
- `gdb-multiarch` para debug
- un ST-Link o compatible

Instalación típica en Ubuntu:

```bash
sudo apt update
sudo apt install gcc-arm-none-eabi openocd gdb-multiarch make
```

## Compilación

```bash
make
```

Esto genera:

- `bin/blink_minimal.elf`: ejecutable con símbolos de depuración
- `bin/blink_minimal.bin`: binario crudo para flashing
- `bin/blink_minimal.map`: mapa de memoria del enlazado

## Flashing

```bash
make flash
```

La regla usa OpenOCD con configuración para ST-Link y STM32F1.

## Debug con GDB

En una terminal:

```bash
make openocd
```

En otra:

```bash
make gdb
```

## Uso con VS Code

El repo incluye configuración pensada para trabajar con Visual Studio Code y la extensión Cortex-Debug.

Flujo sugerido:

1. Abrir el proyecto en VS Code.
2. Compilar con `Ctrl+Shift+B`.
3. Iniciar depuración con `F5`.
4. Usar tareas para `clean` o `flash` si hace falta.

## Alcance

Este repositorio es útil como base para:

- entender startup y linker scripts,
- practicar acceso directo a registros,
- estudiar organización de memoria en Cortex-M,
- preparar el salto a CMSIS, libopencm3 o FreeRTOS con más contexto.

## Documentación técnica

Los documentos principales están en `docs/`:

- [main.md](docs/main.md): análisis del ejemplo de blink.
- [startup.md](docs/startup.md): arranque del sistema después del reset.
- [linker.md](docs/linker.md): distribución de secciones en memoria.
- [toolchain.md](docs/toolchain.md): herramientas de compilación, enlace, flashing y debug.

## Licencia

Este proyecto se distribuye bajo la [Licencia MIT](LICENSE).
