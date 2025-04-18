[bits 16]
[org 0x7C00]

KERNEL_OFFSET equ 0x500
KERNEL_SECTORS equ 8

xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7C00

mov [BOOT_DRIVE], dl

mov si, BOOT_MSG
call print_string

mov si, RESET_MSG
call print_string

xor ah, ah
mov dl, [BOOT_DRIVE]
int 0x13
jc disk_error

mov si, LOAD_START_MSG
call print_string

mov ah, 0x02
mov al, KERNEL_SECTORS
mov ch, 0
mov cl, 2
mov dh, 0
mov dl, [BOOT_DRIVE]
mov bx, KERNEL_OFFSET
int 0x13
jc disk_error

mov si, VERIFY_MSG
call print_string

cmp al, KERNEL_SECTORS
jne sector_error

mov si, SUCCESS_MSG
call print_string

mov si, JUMP_MSG
call print_string

jmp KERNEL_OFFSET

disk_error:
    mov si, DISK_ERROR_MSG
    call print_string
    jmp $

sector_error:
    mov si, SECTOR_ERROR_MSG
    call print_string
    jmp $

print_string:
    pusha
.next_char:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .next_char
.done:
    popa
    ret

BOOT_MSG         db 'LoxOS Bootloader starting...', 13, 10, 0
RESET_MSG        db 'Resetting disk system...', 13, 10, 0
LOAD_START_MSG   db 'Reading kernel sectors...', 13, 10, 0
VERIFY_MSG       db 'Verifying sector count...', 13, 10, 0
SUCCESS_MSG      db 'Kernel loaded successfully.', 13, 10, 0
DISK_ERROR_MSG   db 'Disk read error occurred!', 13, 10, 0
SECTOR_ERROR_MSG db 'Mismatch in number of sectors read!', 13, 10, 0
JUMP_MSG         db 'Jumping to kernel...', 13, 10, 0
BOOT_DRIVE       db 0

times 510-($-$$) db 0
dw 0xAA55
