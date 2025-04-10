# Nombre del ejecutable (sin extensión)
TARGET = blink_minimal

# Compilador
CC = arm-none-eabi-gcc

# Flags del compilador:
# -Wall y -Wextra habilitan advertencias comunes
# -mcpu=cortex-m3 especifica el tipo de CPU
# -g incluye información de debugging
CFLAGS = -Wall -Wextra -mcpu=cortex-m3 -g

# Flags del linker:
# -T linker.ld usa un script de linker personalizado
# -nostartfiles evita que se incluyan archivos de inicio estándar
# -Wl,-Map=... genera un archivo .map con el layout del binario
LDFLAGS = -T linker.ld -nostartfiles -mcpu=cortex-m3 -Wl,-Map=$(BIN_DIR)/$(TARGET).map

# Directorios
SRC_DIR = src       # Donde están los archivos .c
OBJ_DIR = obj       # Donde se guardarán los archivos .o (objetos)
BIN_DIR = bin       # Donde se genera el binario final (.elf, .bin, .map)


# Lista de archivos fuente (*.c) en el directorio de código fuente
# `wildcard` es una función de Make que expande patrones de archivos.
# En este caso, busca todos los archivos que coincidan con `src/*.c` y devuelve la lista.
# Por ejemplo, si hay `src/main.c` y `src/utils.c`, se expandirá como:
# SRC_FILES = src/main.c src/utils.c
SRC_FILES = $(wildcard $(SRC_DIR)/*.c)

# Lista de archivos objeto (*.o), transformando src/archivo.c → obj/archivo.o
# La función `patsubst` reemplaza el patrón de la izquierda por el de la derecha.
# % es un comodín que representa el nombre base del archivo (sin extensión).
OBJ_FILES = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRC_FILES))


# Regla principal: genera el archivo binario desde el ejecutable .elf
# $^ es una variable automática que representa todas las dependencias (acá, el .elf)
# $@ es la variable automática que representa el nombre del target (acá, el .bin)
$(BIN_DIR)/$(TARGET).bin: $(BIN_DIR)/$(TARGET)
	@mkdir -p $(BIN_DIR)          # Crea el directorio bin si no existe
	arm-none-eabi-objcopy -O binary $^ $@

# Regla para generar el ejecutable .elf a partir de los objetos
# $@ es el nombre del ejecutable (.elf), $^ son todos los objetos
$(BIN_DIR)/$(TARGET): $(OBJ_FILES)
	@mkdir -p $(BIN_DIR)          # Crea el directorio bin si no existe
	$(CC) $(LDFLAGS) -o $@ $^

# Regla para compilar cada archivo fuente a un objeto
# $< es la primera dependencia (el .c), $@ es el archivo de salida (.o)
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(OBJ_DIR)          # Crea el directorio obj si no existe
	$(CC) $(CFLAGS) -c -o $@ $<


# Meta-regla: limpiar objetos y binarios generados
# .PHONY indica que no son archivos, sino comandos que siempre deben ejecutarse
.PHONY: clean
clean:
	rm -rf $(OBJ_DIR)/*.o $(BIN_DIR)/$(TARGET)*


# Programar el microcontrolador con OpenOCD
.PHONY: flash
flash: $(BIN_DIR)/$(TARGET)
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "program $^ verify reset exit"

# Abrir OpenOCD sin programar, para usar con GDB por ejemplo
.PHONY: openocd
openocd:
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg

# Conectarse con GDB para debug
.PHONY: gdb
gdb: $(BIN_DIR)/$(TARGET)
	gdb-multiarch $^ -ex "target remote localhost:3333"
