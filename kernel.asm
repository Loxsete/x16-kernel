; Kernel by Loxsete
[bits 16]
[org 0x1000]

start:
    
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    mov si, boot_msg
    call print_string
    call print_newline
    mov si, info_table
    call print_string
    call print_newline

    jmp input_start

input_start:
    mov di, buffer
    xor cx, cx
    mov si, prompt
    call print_string

input_loop:
    mov ah, 0x00
    int 0x16

    cmp al, 0x0d
    je process_command
    cmp al, 0x08
    je handle_backspace
    cmp cx, 31
    je input_loop

    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x07
    int 0x10

    mov [di], al
    inc di
    inc cx
    jmp input_loop

handle_backspace:
    cmp cx, 0
    je input_loop
    dec di
    dec cx
    mov byte [di], 0
    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp input_loop

process_command:
    mov byte [di], 0
    call print_newline
    mov si, buffer

    mov di, cmd_clear
    call strcmp
    jc do_clear

    mov di, cmd_cpuid
    call strcmp
    jc do_cpuid

    mov di, cmd_help
    call strcmp
    jc do_help

    mov di, cmd_info
    call strcmp
    jc do_info

    mov si, error_msg
    call print_string
    call print_newline
    jmp reset_buffer

do_clear:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    jmp reset_buffer

do_cpuid:
    mov eax, 0
    cpuid
    mov si, cpuid_msg
    call print_string
    call print_newline
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x07
    mov al, bl
    int 0x10
    mov al, bh
    int 0x10
    shr ebx, 16
    mov al, bl
    int 0x10
    mov al, bh
    int 0x10
    call print_newline
    jmp reset_buffer

do_help:
    mov si, help_msg
    call print_string
    call print_newline
    jmp reset_buffer

do_info:
    mov si, info_table
    call print_string
    call print_newline
    mov si, info_msg
    call print_string
    call print_newline
    jmp reset_buffer

reset_buffer:
    mov di, buffer
    xor cx, cx
    mov si, prompt
    call print_string
    jmp input_loop

print_string:
print_loop:
    lodsb
    cmp al, 0
    je print_done
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp print_loop
print_done:
    ret

print_newline:
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x07
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    int 0x10
    ret

strcmp:
    push si
    push di
strcmp_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne strcmp_not_equal
    cmp al, 0
    je strcmp_equal
    inc si
    inc di
    jmp strcmp_loop
strcmp_not_equal:
    clc
    pop di
    pop si
    ret
strcmp_equal:
    stc
    pop di
    pop si
    ret

boot_msg:   db 'System Booted', 0
prompt:     db '> ', 0
error_msg:  db 'Unknown command', 0
help_msg:   db 'Commands: clear, cpuid, help, info', 0
cpuid_msg:  db 'CPU Info:', 0
info_msg:   db 'Test mini kernel', 0

cmd_clear:  db 'clear', 0
cmd_cpuid:  db 'cpuid', 0
cmd_help:   db 'help', 0
cmd_info:   db 'info', 0

info_table: db '+------------+', 0x0a, 0x0d
            db '| Test OS    |', 0x0a, 0x0d
            db '| By Loxsete |', 0x0a, 0x0d
            db '+------------+', 0x0a, 0x0d, 0

buffer:     times 32 db 0