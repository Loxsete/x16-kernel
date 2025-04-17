[bits 16]
[org 0x7E00]

kernel_start:
    mov ah, 0x00
    mov al, 0x13
    int 0x10

    mov si, info_msg1
    call print_string
    call print_newline

    call do_info

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

    mov di, cmd_mem
    call strcmp
    jc do_mem

    mov si, error_msg
    call print_string
    call print_newline
    jmp reset_buffer

do_clear:
    mov ah, 0x00
    mov al, 0x13
    int 0x10
    jmp reset_buffer

do_cpuid:
    mov si, cpuid_msg
    call print_string
    call print_newline

    mov eax, 0
    cpuid

    mov si, vendor_msg
    call print_string

    push eax
    push ebx
    push ecx
    push edx

    mov [temp_buffer], ebx
    mov [temp_buffer+4], edx
    mov [temp_buffer+8], ecx
    mov byte [temp_buffer+12], 0

    mov si, temp_buffer
    call print_string
    call print_newline

    pop edx
    pop ecx
    pop ebx
    pop eax

    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000004
    jb .no_brand_string

    mov si, name_msg
    call print_string

    mov edi, temp_buffer

    mov eax, 0x80000002
    cpuid
    mov [edi], eax
    mov [edi+4], ebx
    mov [edi+8], ecx
    mov [edi+12], edx
    add edi, 16

    mov eax, 0x80000003
    cpuid
    mov [edi], eax
    mov [edi+4], ebx
    mov [edi+8], ecx
    mov [edi+12], edx
    add edi, 16

    mov eax, 0x80000004
    cpuid
    mov [edi], eax
    mov [edi+4], ebx
    mov [edi+8], ecx
    mov [edi+12], edx

    mov byte [edi+16], 0

    mov si, temp_buffer
    call print_string
    call print_newline

.no_brand_string:
    mov eax, 1
    cpuid

    mov eax, 0
    cpuid
    cmp eax, 0xB
    jb .simple_thread_count

    mov eax, 1
    cpuid
    mov eax, ebx
    shr eax, 16
    and eax, 0xFF

    mov si, threads_msg
    call print_string

    push eax
    call print_decimal
    pop eax

    call print_newline
    jmp .cpuid_done

.simple_thread_count:
    mov si, unknown_cores_msg
    call print_string
    call print_newline

.cpuid_done:
    call print_newline
    jmp reset_buffer

print_decimal:
    push ax
    push bx
    push cx
    push dx

    xor cx, cx
    mov bx, 10

.convert_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .convert_loop

.print_loop:
    pop dx
    add dl, '0'
    mov ah, 0x0E
    mov al, dl
    int 0x10
    loop .print_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret

do_help:
    mov si, help_msg
    call print_string
    call print_newline
    jmp reset_buffer

do_info:
    mov si, info_border
    call print_string
    call print_newline

    mov si, info_row1
    call print_string
    call print_newline

    mov si, info_row2
    call print_string
    call print_newline

    mov si, info_row3
    call print_string
    call print_newline

    mov si, info_row4
    call print_string
    call print_newline

    mov si, info_row5
    call print_string
    call print_newline

    mov si, info_row6
    call print_string
    call print_newline

    mov si, info_row7
    call print_string
    call print_newline

    mov si, info_row8
    call print_string
    call print_newline

    mov si, info_row9
    call print_string
    call print_newline

    mov si, info_border
    call print_string
    call print_newline
    jmp reset_buffer

do_mem:
    int 0x12
    mov si, mem_msg
    call print_string

    mov bx, ax
    mov al, bh
    call print_hex
    mov al, bl
    call print_hex

    call print_newline
    jmp reset_buffer

reset_buffer:
    mov di, buffer
    xor cx, cx
    mov si, prompt
    call print_string
    jmp input_loop

print_string:
    push ax
    push bx
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
    pop bx
    pop ax
    ret

print_newline:
    push ax
    push bx
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x07
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    pop bx
    pop ax
    ret

print_hex:
    push ax
    shr al, 4
    call print_nibble
    pop ax
    and al, 0x0F
    call print_nibble
    ret

print_nibble:
    cmp al, 10
    jl .digit
    add al, 'A' - 10
    jmp .print
.digit:
    add al, '0'
.print:
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x07
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

prompt     db '> ', 0
error_msg  db 'Unknown command', 0
help_msg   db 'Commands: clear, cpuid, help, info, mem', 0
cpuid_msg  db 'CPU Info:', 0
info_msg1  db 'Welcone to LoxOS 0.2! Thanks for testing', 0
mem_msg    db 'RAM memory size: 0x', 0
temp_buffer     times 64 db 0
vendor_msg     db 'Vendor: ', 0
name_msg       db 'CPU Name: ', 0
threads_msg    db 'Logical Processors: ', 0
unknown_cores_msg db 'CPU cores: Cannot determine', 0
info_border db '+----------------------------------------+', 0
info_row1   db '| LoxOS 0.1                             |', 0
info_row2   db '| Created by Loxsete                    |', 0
info_row3   db '| Mode: 0x13 graphics                   |', 0
info_row4   db '| Kernel: Mini, 16-bit                  |', 0
info_row5   db '| Commands:                             |', 0
info_row6   db '| help  - show help                     |', 0
info_row7   db '| mem   - show RAM                      |', 0
info_row8   db '| clear - clear screen                  |', 0
info_row9   db '| cpuid - show CPU Info                 |', 0
cmd_clear  db 'clear', 0
cmd_cpuid  db 'cpuid', 0
cmd_help   db 'help', 0
cmd_info   db 'info', 0
cmd_mem    db 'mem', 0
buffer     times 256 db 0
