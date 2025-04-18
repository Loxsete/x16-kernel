NASM = nasm
DD = dd
CAT = cat
MKISOFS = genisoimage
XORRISO = xorriso

BOOTLOADER = boot.asm
KERNEL = kernel.asm
FLOPPY_IMAGE = loxos.img
USB_IMAGE = loxos_usb.img
ISO_IMAGE = loxos.iso

ISO_DIR = iso_root
ISO_BOOT_DIR = $(ISO_DIR)/boot

all: $(FLOPPY_IMAGE) $(USB_IMAGE) $(ISO_IMAGE)

$(FLOPPY_IMAGE): bootloader.bin kernel.bin
	$(DD) if=/dev/zero of=$(FLOPPY_IMAGE) bs=1024 count=1440
	$(DD) if=bootloader.bin of=$(FLOPPY_IMAGE) conv=notrunc
	$(DD) if=kernel.bin of=$(FLOPPY_IMAGE) seek=1 conv=notrunc

$(USB_IMAGE): bootloader.bin kernel.bin
	$(DD) if=/dev/zero of=$(USB_IMAGE) bs=1M count=16
	echo -e "o\nn\np\n1\n\n\na\n1\nw" | fdisk $(USB_IMAGE) || true
	$(DD) if=bootloader.bin of=$(USB_IMAGE) conv=notrunc
	$(DD) if=kernel.bin of=$(USB_IMAGE) seek=1 conv=notrunc

$(ISO_IMAGE): bootloader.bin kernel.bin
	$(DD) if=/dev/zero of=floppy.img bs=1024 count=1440
	$(DD) if=bootloader.bin of=floppy.img conv=notrunc
	$(DD) if=kernel.bin of=floppy.img seek=1 conv=notrunc
	mkdir -p $(ISO_BOOT_DIR)
	cp floppy.img $(ISO_BOOT_DIR)/
	if command -v $(XORRISO) >/dev/null 2>&1; then \
		$(XORRISO) -as mkisofs -o $(ISO_IMAGE) -b boot/floppy.img \
			-c boot/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table $(ISO_DIR); \
	else \
		$(MKISOFS) -o $(ISO_IMAGE) -b boot/floppy.img -c boot/boot.cat \
			-no-emul-boot -boot-load-size 4 -boot-info-table $(ISO_DIR); \
	fi
	rm -f floppy.img

bootloader.bin: $(BOOTLOADER)
	$(NASM) -f bin $(BOOTLOADER) -o bootloader.bin

kernel.bin: $(KERNEL)
	$(NASM) -f bin $(KERNEL) -o kernel.bin

run-floppy: $(FLOPPY_IMAGE)
	qemu-system-i386 -fda $(FLOPPY_IMAGE)

run-hd: $(FLOPPY_IMAGE)
	qemu-system-i386 -drive file=$(FLOPPY_IMAGE),format=raw

run-usb: $(USB_IMAGE)
	qemu-system-i386 -machine q35 -usb -device usb-ehci,id=ehci \
		-device usb-storage,bus=ehci.0,drive=disk \
		-drive file=$(USB_IMAGE),format=raw,if=none,id=disk

run-usb-debug: $(USB_IMAGE)
	qemu-system-i386 -machine q35 -usb -device usb-ehci,id=ehci \
		-device usb-storage,bus=ehci.0,drive=disk \
		-drive file=$(USB_IMAGE),format=raw,if=none,id=disk \
		-monitor stdio -d int -D qemu.log

run-iso: $(ISO_IMAGE)
	qemu-system-i386 -boot d -cdrom $(ISO_IMAGE)

run-iso-debug: $(ISO_IMAGE)
	qemu-system-i386 -boot d -cdrom $(ISO_IMAGE) -monitor stdio -d int -D qemu.log

run-iso-only: $(ISO_IMAGE)
	qemu-system-i386 -boot d -cdrom $(ISO_IMAGE) -net none

run-debug: $(FLOPPY_IMAGE)
	qemu-system-i386 -fda $(FLOPPY_IMAGE) -serial stdio -display sdl

usb: $(FLOPPY_IMAGE)
	@echo "Внимание: Это сотрет все данные на $(DEVICE)!"
	@echo "Нажмите Ctrl+C для отмены или Enter для продолжения."
	@read
	$(DD) if=$(FLOPPY_IMAGE) of=$(DEVICE)

clean:
	rm -f *.bin $(FLOPPY_IMAGE) $(USB_IMAGE) $(ISO_IMAGE) qemu.log floppy.img
	rm -rf $(ISO_DIR)

.PHONY: all run-floppy run-hd run-usb run-usb-debug run-iso run-iso-debug run-iso-only run-debug clean usb
