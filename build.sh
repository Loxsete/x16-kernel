#!/bin/bash

# Определение переменных
NASM=nasm
DD=dd
CAT=cat
MKISOFS=genisoimage
XORRISO=xorriso

BOOTLOADER=boot.asm
KERNEL=kernel.asm
FLOPPY_IMAGE=loxos.img
USB_IMAGE=loxos_usb.img
ISO_IMAGE=loxos.iso

ISO_DIR=iso_root
ISO_BOOT_DIR=$ISO_DIR/boot

# Функции для целей
build_bootloader() {
    $NASM -f bin $BOOTLOADER -o bootloader.bin
}

build_kernel() {
    $NASM -f bin $KERNEL -o kernel.bin
}

build_floppy() {
    build_bootloader
    build_kernel
    $DD if=/dev/zero of=$FLOPPY_IMAGE bs=1024 count=1440
    $DD if=bootloader.bin of=$FLOPPY_IMAGE conv=notrunc
    $DD if=kernel.bin of=$FLOPPY_IMAGE seek=1 conv=notrunc
}

build_usb() {
    build_bootloader
    build_kernel
    $DD if=/dev/zero of=$USB_IMAGE bs=1M count=16
    echo -e "o\nn\np\n1\n\n\na\n1\nw" | fdisk $USB_IMAGE || true
    $DD if=bootloader.bin of=$USB_IMAGE conv=notrunc
    $DD if=kernel.bin of=$USB_IMAGE seek=1 conv=notrunc
}

build_iso() {
    build_bootloader
    build_kernel
    $DD if=/dev/zero of=floppy.img bs=1024 count=1440
    $DD if=bootloader.bin of=floppy.img conv=notrunc
    $DD if=kernel.bin of=floppy.img seek=1 conv=notrunc
    mkdir -p $ISO_BOOT_DIR
    cp floppy.img $ISO_BOOT_DIR/
    if command -v $XORRISO >/dev/null 2>&1; then
        $XORRISO -as mkisofs -o $ISO_IMAGE -b boot/floppy.img \
            -c boot/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table $ISO_DIR
    else
        $MKISOFS -o $ISO_IMAGE -b boot/floppy.img -c boot/boot.cat \
            -no-emul-boot -boot-load-size 4 -boot-info-table $ISO_DIR
    fi
    rm -f floppy.img
}

run_floppy() {
    build_floppy
    qemu-system-i386 -fda $FLOPPY_IMAGE
}

run_hd() {
    build_floppy
    qemu-system-i386 -drive file=$FLOPPY_IMAGE,format=raw
}

run_usb() {
    build_usb
    qemu-system-i386 -machine q35 -usb -device usb-ehci,id=ehci \
        -device usb-storage,bus=ehci.0,drive=disk \
        -drive file=$USB_IMAGE,format=raw,if=none,id=disk
}

run_usb_debug() {
    build_usb
    qemu-system-i386 -machine q35 -usb -device usb-ehci,id=ehci \
        -device usb-storage,bus=ehci.0,drive=disk \
        -drive file=$USB_IMAGE,format=raw,if=none,id=disk \
        -monitor stdio -d int -D qemu.log
}

run_iso() {
    build_iso
    qemu-system-i386 -boot d -cdrom $ISO_IMAGE
}

run_iso_debug() {
    build_iso
    qemu-system-i386 -boot d -cdrom $ISO_IMAGE -monitor stdio -d int -D qemu.log
}

run_iso_only() {
    build_iso
    qemu-system-i386 -boot d -cdrom $ISO_IMAGE -net none
}

run_debug() {
    build_floppy
    qemu-system-i386 -fda $FLOPPY_IMAGE -serial stdio -display sdl
}

usb() {
    build_floppy
    echo "Внимание: Это сотрет все данные на $DEVICE!"
    echo "Нажмите Ctrl+C для отмены или Enter для продолжения."
    read
    $DD if=$FLOPPY_IMAGE of=$DEVICE
}

clean() {
    rm -f *.bin $FLOPPY_IMAGE $USB_IMAGE $ISO_IMAGE qemu.log floppy.img
    rm -rf $ISO_DIR
}

# Основная логика
case "$1" in
    all)
        build_floppy
        build_usb
        build_iso
        ;;
    run-floppy)
        run_floppy
        ;;
    run-hd)
        run_hd
        ;;
    run-usb)
        run_usb
        ;;
    run-usb-debug)
        run_usb_debug
        ;;
    run-iso)
        run_iso
        ;;
    run-iso-debug)
        run_iso_debug
        ;;
    run-iso-only)
        run_iso_only
        ;;
    run-debug)
        run_debug
        ;;
    usb)
        if [ -z "$2" ]; then
            echo "Укажите устройство (например, /dev/sdb)"
            exit 1
        fi
        DEVICE=$2
        usb
        ;;
    clean)
        clean
        ;;
    *)
        echo "Использование: $0 {all|run-floppy|run-hd|run-usb|run-usb-debug|run-iso|run-iso-debug|run-iso-only|run-debug|usb DEVICE|clean}"
        exit 1
        ;;
esac
