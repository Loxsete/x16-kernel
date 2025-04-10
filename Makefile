
# Makefile для сборки загрузчика и ядра

# Компилятор и флаги
NASM = nasm
NASM_FLAGS = -f bin

# Имена файлов
BOOT_SRC = boot.asm
KERNEL_SRC = kernel.asm
BOOT_BIN = boot.bin
KERNEL_BIN = kernel.bin
OUTPUT = os_image.bin

# Цели
all: $(OUTPUT)

# Сборка загрузчика
$(BOOT_BIN): $(BOOT_SRC)
	$(NASM) $(NASM_FLAGS) $(BOOT_SRC) -o $(BOOT_BIN)

# Сборка ядра
$(KERNEL_BIN): $(KERNEL_SRC)
	$(NASM) $(NASM_FLAGS) $(KERNEL_SRC) -o $(KERNEL_BIN)

# Объединение загрузчика и ядра в один образ
$(OUTPUT): $(BOOT_BIN) $(KERNEL_BIN)
	cat $(BOOT_BIN) $(KERNEL_BIN) > $(OUTPUT)

# Очистка
clean:
	rm -f $(BOOT_BIN) $(KERNEL_BIN) $(OUTPUT)

# Тест в QEMU (опционально, если установлен)
run: $(OUTPUT)
	qemu-system-x86_64 -fda $(OUTPUT)

.PHONY: all clean run