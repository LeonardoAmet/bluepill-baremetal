# 🧵 bluepill-baremetal

🎯 **Proyecto minimalista para programar la Blue Pill (STM32F103C8T6) en bare-metal usando WSL2.**  
Sin HAL, sin magia: solo registros, C puro y un Makefile simple. Ideal para aprender cómo funciona todo desde adentro 🔍⚙️

---

## 📦 Estructura del proyecto

```
bluepill-baremetal/
├── src/               # Código fuente en C (sin HAL)
├── bin/               # Binarios generados (.elf, .bin, .map)
├── obj/               # Archivos objeto intermedios
├── linker.ld          # Script de linker personalizado
├── Makefile           # Build system simple y transparente
└── README.md          # Este archivo ✍️
```

---

## 🚀 Cómo compilar y flashear

Este proyecto está pensado para usarse con **WSL2 + arm-none-eabi-gcc + OpenOCD**.

### 🔧 Requisitos

- [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install)
- Toolchain ARM:
  ```bash
  sudo apt install gcc-arm-none-eabi
  ```
- OpenOCD:
  ```bash
  sudo apt install openocd
  ```
- ST-Link conectado por USB

### 🔨 Compilar

```bash
make
```

Esto genera:

- `bin/blink_minimal.elf`: binario ELF con info de depuración 🧠
- `bin/blink_minimal.bin`: binario puro para flashear 🚀
- `bin/blink_minimal.map`: mapa de memoria 📊

### ⚡ Flashear la placa

```bash
make flash
```

> Usa OpenOCD con configuración para ST-Link y STM32F1.

### 🐛 Debug con GDB

1. En una terminal:
   ```bash
   make openocd
   ```

2. En otra:
   ```bash
   make gdb
   ```

---

## 🎓 Ideal para...

- Estudiantes de sistemas embebidos
- Docentes que quieren enseñar desde lo más bajo nivel
- Curiosos del hardware que prefieren saber **exactamente qué está pasando**

---

## 📚 Expansiones sugeridas

- Agregar manejo de interrupciones 🧠
- Controlar periféricos como GPIO, USART, ADC, etc. 💡
- Agregar FreeRTOS desde cero 🧵

---

## 🧠

> “No se puede controlar lo que no se comprende.”  
> — Richard Feynman, probablemente

---

## 🪪 Licencia

Este proyecto está licenciado bajo los términos de la [Licencia MIT](LICENSE).

