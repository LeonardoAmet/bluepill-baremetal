

TARGET = blink_minimal

CC = arm-none-eabi-gcc
CFLAGS = -Wall -Wextra -mcpu=cortex-m3  -g
LDFLAGS = -T linker.ld -nostartfiles -mcpu=cortex-m3 -Wl,-Map=$(BIN_DIR)/$(TARGET).map

SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

SRC_FILES = $(wildcard $(SRC_DIR)/*.c)
OBJ_FILES = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRC_FILES))


$(BIN_DIR)/$(TARGET).bin: $(BIN_DIR)/$(TARGET)
	arm-none-eabi-objcopy  -O binary $^ $@ 

$(BIN_DIR)/$(TARGET): $(OBJ_FILES)
	$(CC) $(LDFLAGS) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<



.PHONY: clean
clean:
	rm -rf $(OBJ_DIR)/*.o $(BIN_DIR)/$(TARGET)*

# .PHONY: flash
# flash: $(BIN_DIR)/$(TARGET).bin
# 	STM32_Programmer_CLI -c port=SWD -w $(BIN_DIR)/$(TARGET).bin  0x08000000

# run: flash
# 	STM32_Programmer_CLI -c port=SWD -s
# flash:  $(BIN_DIR)/$(TARGET) 
# 	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "program $< verify reset exit"

.PHONY: flash
flash:$(BIN_DIR)/$(TARGET)
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "program $(BIN_DIR)/$(TARGET) verify reset exit"
# 	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg -c "program ./bin/blink-minimal verify reset exit"

.PHONY: openocd
openocd:
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg 

.PHONY: gdb
gdb: $(BIN_DIR)/$(TARGET)
	gdb-multiarch $(BIN_DIR)/$(TARGET) -ex "target remote localhost:3333"
