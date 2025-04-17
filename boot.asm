; ==== BOOTLOADER ====
[bits 16]
[org 0x7c00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti


    mov si, boot_info
    call print_string


    mov ah, 0x02
    mov al, 4
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0
    mov bx, 0x7E00
    int 0x13

    jc disk_error

    jmp 0x7E00

disk_error:
    mov si, error_msg
    call print_string
    jmp $

print_string:
    lodsb
    cmp al, 0
    je print_done
    mov ah, 0x0e
    mov bx, 0x07
    int 0x10
    jmp print_string
print_done:
    ret

boot_info: db '+-------------------------+', 0x0a, 0x0d
           db '|      LoxOS Bootloader   |', 0x0a, 0x0d
           db '|-------------------------|', 0x0a, 0x0d
           db '| Developer: Loxsete      |', 0x0a, 0x0d
           db '| Type: 16-bit Bootloader |', 0x0a, 0x0d
           db '| Features:               |', 0x0a, 0x0d
           db '|  - Disk Loading         |', 0x0a, 0x0d
           db '|  - Error Handling       |', 0x0a, 0x0d
           db '|  - Protected Mode Jump  |', 0x0a, 0x0d
           db '+-------------------------+', 0x0a, 0x0d, 0

error_msg: db 'Disk read error', 0

times 510-($-$$) db 0
dw 0xaa55
