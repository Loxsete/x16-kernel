[bits 16]
[org 500h]

kernel_start:
    mov ah, 0x00
    mov al, 0x12
    int 0x10

    mov si, ASCII_art
    call print_string
    call print_newline

    call do_info

    jmp input_start

input_start:
    mov di, buffer
    xor cx, cx
    mov si, prompt
    call print_string

    mov bx, 0
    mov dx, 3

input_loop:
    mov ah, 0x00
    int 0x16

    cmp al, 0x0d
    je process_command

    cmp al, 0x08
    je handle_backspace

    cmp al, 0x48
    je handle_up_arrow

    cmp al, 0x50
    je handle_down_arrow

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

handle_up_arrow:
    cmp bx, 0
    je input_loop
    dec bx
    jmp input_loop

handle_down_arrow:
    cmp bx, dx
    je input_loop
    inc bx
    jmp input_loop

process_command:
    mov byte [di], 0
    call print_newline

    mov si, buffer
    mov di, cmd_clear
    call strcmp_first_word
    jc do_clear

    mov si, buffer
    mov di, cmd_cpuid
    call strcmp_first_word
    jc do_cpuid

    mov si, buffer
    mov di, cmd_help
    call strcmp_first_word
    jc do_help

    mov si, buffer
    mov di, cmd_info
    call strcmp_first_word
    jc do_info

    mov si, buffer
    mov di, cmd_mem
    call strcmp_first_word
    jc do_mem

    mov si, buffer
    mov di, cmd_dump
    call strcmp_first_word
    jc do_dump

    mov si, buffer
    mov di, cmd_reboot
    call strcmp_first_word
    jc do_reboot

    mov si, buffer
    mov di, cmd_time
    call strcmp_first_word
    jc do_time

    mov si, error_msg
    mov cl, 0x0C
    call print_string_color
    call print_newline
    jmp reset_buffer

do_clear:
    mov ah, 0x00
    mov al, 0x12
    int 0x10
    jmp reset_buffer

do_dump:
    mov ax, 0
    mov es, ax

    mov si, buffer
    call skip_word
    cmp byte [si], 0
    je .use_default

    call parse_hex
    mov bx, ax
    call skip_word
    cmp byte [si], 0
    je .use_default_count

    call parse_hex
    mov dx, ax
    cmp dx, 0
    je .use_default_count
    jmp .validate_count

.use_default:
    mov bx, 0
.use_default_count:
    mov dx, 256

.validate_count:
    cmp dx, 4096
    jbe .count_ok
    mov dx, 4096
.count_ok:

    mov [last_dump_addr], bx
    mov [last_dump_count], dx

.start_dump:
    mov si, dump_header
    call print_string
    call print_newline

    mov si, dump_address_msg
    call print_string
    mov ax, bx
    call print_hex
    call print_newline

    mov ax, dx
    mov cx, 16
    xor dx, dx
    div cx
    cmp dx, 0
    je .no_extra_line
    inc ax
.no_extra_line:
    mov cx, ax

.dump_line:
    push cx
    push bx

    mov ax, bx
    call print_address

    mov di, temp_buffer
    mov cx, 16

.dump_bytes:
    cmp word [last_dump_count], 0
    je .fill_spaces

    mov al, [es:bx]
    dec word [last_dump_count]

    cmp al, 32
    jl .non_printable
    cmp al, 126
    jg .non_printable
    jmp .printable

.non_printable:
    mov byte [di], '.'
    jmp .store_ascii

.printable:
    mov [di], al

.store_ascii:
    inc di

    call print_hex

    mov ax, bx
    and ax, 0x03
    cmp ax, 0x03
    je .double_space
    call print_space
    jmp .next_byte
.double_space:
    call print_space
    call print_space

.next_byte:
    inc bx
    loop .dump_bytes
    jmp .print_ascii

.fill_spaces:
    mov byte [di], ' '
    inc di
    mov al, ' '
    call print_hex
    call print_space
    loop .fill_spaces

.print_ascii:
    call print_space
    call print_space
    mov byte [di], 0
    mov si, temp_buffer
    call print_string

    call print_newline

    pop bx
    add bx, 16
    pop cx
    dec cx
    jnz .dump_line

    call print_newline

    mov [last_dump_addr], bx
    jmp reset_buffer

last_dump_addr  dw 0
last_dump_count dw 0

skip_word:
    cmp byte [si], 0
    je .done
    cmp byte [si], ' '
    je .skip_spaces
    inc si
    jmp skip_word

.skip_spaces:
    inc si
    cmp byte [si], ' '
    je .skip_spaces

.done:
    ret

parse_hex:
    xor ax, ax

.parse_loop:
    cmp byte [si], 0
    je .done
    cmp byte [si], ' '
    je .done

    shl ax, 4

    mov bl, [si]

    cmp bl, '0'
    jl .error
    cmp bl, '9'
    jle .digit

    cmp bl, 'A'
    jl .error
    cmp bl, 'F'
    jle .upper_letter

    cmp bl, 'a'
    jl .error
    cmp bl, 'f'
    jle .lower_letter
    jmp .error

.digit:
    sub bl, '0'
    jmp .add_digit

.upper_letter:
    sub bl, 'A'
    add bl, 10
    jmp .add_digit

.lower_letter:
    sub bl, 'a'
    add bl, 10

.add_digit:
    add al, bl
    inc si
    jmp .parse_loop

.error:
    xor ax, ax

.done:
    ret

print_space:
    push ax
    mov al, ' '
    mov ah, 0x0e
    mov bx, 0
    mov bl, 0x07
    int 0x10
    pop ax
    ret

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
    mov si, buffer
    call skip_word
    cmp byte [si], 0
    je .show_general_help

    mov di, cmd_clear
    call strcmp_first_word
    jc .help_clear

    mov di, cmd_cpuid
    call strcmp_first_word
    jc .help_cpuid

    mov di, cmd_help
    call strcmp_first_word
    jc .help_help

    mov di, cmd_info
    call strcmp_first_word
    jc .help_info

    mov di, cmd_mem
    call strcmp_first_word
    jc .help_mem

    mov di, cmd_dump
    call strcmp_first_word
    jc .help_dump

    mov di, cmd_reboot
    call strcmp_first_word
    jc .help_reboot

    mov di, cmd_time
    call strcmp_first_word
    jc .help_time

    mov si, help_error_msg
    mov cl, 0x0C
    call print_string_color
    call print_newline
    jmp reset_buffer

.show_general_help:
    mov si, help_header
    mov cl, 0x0E
    call print_string_color
    call print_newline

    mov si, help_clear
    mov cl, 0x07
    call print_string_color
    call print_newline

    mov si, help_cpuid
    mov cl, 0x07
    call print_string_color
    call print_newline

    mov si, help_help
    mov cl, 0x07
    call print_string_color
    call print_newline

    mov si, help_info
    mov cl, 0x07
    call print_string_color
    call print_newline

    mov si, help_mem
    mov cl, 0x07
    call print_string_color
    call print_newline

    mov si, help_dump
    mov cl, 0x07
    call print_string_color
    call print_newline

    mov si, help_reboot
    mov cl, 0x07
    call print_string_color
    call print_newline

    mov si, help_time
    mov cl, 0x07
    call print_string_color
    call print_newline

    call print_newline
    jmp reset_buffer

.help_clear:
    mov si, help_clear_detail
    mov cl, 0x07
    call print_string_color
    call print_newline
    jmp reset_buffer

.help_cpuid:
    mov si, help_cpuid_detail
    mov cl, 0x07
    call print_string_color
    call print_newline
    jmp reset_buffer

.help_help:
    mov si, help_help_detail
    mov cl, 0x07
    call print_string_color
    call print_newline
    jmp reset_buffer

.help_info:
    mov si, help_info_detail
    mov cl, 0x07
    call print_string_color
    call print_newline
    jmp reset_buffer

.help_mem:
    mov si, help_mem_detail
    mov cl, 0x07
    call print_string_color
    call print_newline
    jmp reset_buffer

.help_dump:
    mov si, help_dump_detail
    mov cl, 0x07
    call print_string_color
    call print_newline
    jmp reset_buffer

.help_reboot:
    mov si, help_reboot_detail
    mov cl, 0x07
    call print_string_color
    call print_newline
    jmp reset_buffer

.help_time:
    mov si, help_time_detail
    mov cl, 0x07
    call print_string_color
    call print_newline
    jmp reset_buffer

do_reboot:
    mov si, reboot_msg
    call print_string
    call print_newline
    jmp 0xFFFF:0x0000

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

    mov si, info_row10
    call print_string
    call print_newline

    mov si, info_row11
    call print_string
    call print_newline

    mov si, info_row12
    call print_string
    call print_newline

    mov si, info_border
    call print_string
    call print_newline
    jmp reset_buffer

do_mem:
    mov si, dump_header
    call print_string
    call print_newline

    mov ax, 0x0000
    mov es, ax
    mov bx, 0x0000
    mov dx, 256

    mov cx, 16

.dump_line:
    push cx
    push bx

    mov ax, bx
    call print_address

    mov di, temp_buffer
    mov cx, 16

.dump_bytes:
    mov al, [es:bx]

    cmp al, 32
    jl .non_printable
    cmp al, 126
    jg .non_printable
    jmp .printable

.non_printable:
    mov byte [di], '.'
    jmp .store_ascii

.printable:
    mov [di], al

.store_ascii:
    inc di

    call print_hex

    mov ax, bx
    and ax, 0x03
    cmp ax, 0x03
    je .double_space
    call print_space
    jmp .next_byte
.double_space:
    call print_space
    call print_space

.next_byte:
    inc bx
    loop .dump_bytes

    call print_space
    call print_space
    mov byte [di], 0
    mov si, temp_buffer
    call print_string

    call print_newline

    pop bx
    add bx, 16
    pop cx
    dec cx
    jnz .dump_line

    call print_newline
    jmp reset_buffer

do_time:
    mov si, time_msg
    call print_string

    mov al, 0x04
    out 0x70, al
    in al, 0x71
    call print_hex
    mov al, ':'
    call print_char

    mov al, 0x02
    out 0x70, al
    in al, 0x71
    call print_hex
    mov al, ':'
    call print_char

    mov al, 0x00
    out 0x70, al
    in al, 0x71
    call print_hex

    call print_newline
    jmp reset_buffer

print_char:
    push ax
    push bx
    mov ah, 0x0e
    mov bh, 0
    mov bl, 0x07
    int 0x10
    pop bx
    pop ax
    ret

print_string_color:
    push ax
    push bx
    mov bl, cl
print_loop_color:
    lodsb
    cmp al, 0
    je print_done_color
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    jmp print_loop_color
print_done_color:
    pop bx
    pop ax
    ret

print_address:
    push ax
    push bx
    call print_hex
    mov al, ':'
    call print_char
    mov al, ' '
    call print_char
    pop bx
    pop ax
    ret

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

strcmp_first_word:
    push si
    push di
strcmp_first_loop:
    mov al, [si]
    mov bl, [di]

    cmp bl, 0
    jne .continue_compare

    cmp al, 0
    je strcmp_first_equal
    cmp al, ' '
    je strcmp_first_equal
    jmp strcmp_first_not_equal

.continue_compare:
    cmp al, bl
    jne strcmp_first_not_equal
    cmp al, 0
    je strcmp_first_equal
    inc si
    inc di
    jmp strcmp_first_loop

strcmp_first_not_equal:
    clc
    pop di
    pop si
    ret

strcmp_first_equal:
    stc
    pop di
    pop si
    ret

prompt     db 'Lox > ', 0
error_msg  db 'Unknown command', 0

help_header        db 'LoxOS Help: Available Commands', 0
help_error_msg     db 'Error: Unknown command for help', 0

help_clear         db 'clear   - Clear the screen', 0
help_cpuid         db 'cpuid   - Display CPU information', 0
help_help          db 'help    - Show this help (use "help <cmd>" for details)', 0
help_info          db 'info    - Show system information', 0
help_mem           db 'mem     - Dump first 256 bytes of RAM', 0
help_dump          db 'dump    - Dump memory at address (e.g., dump 0x100 64)', 0
help_reboot        db 'reboot  - Reboot the system', 0
help_time          db 'time    - Show system time from CMOS', 0

help_clear_detail  db 'clear: Clears the screen and resets the display to VGA mode 0x12 (640x480, 16 colors).', 0
help_cpuid_detail  db 'cpuid: Displays CPU vendor, name, and logical processor count using CPUID instruction.', 0
help_help_detail   db 'help: Shows a list of commands. Use "help <command>" for detailed information.', 0
help_info_detail   db 'info: Displays system information, including version, mode, and available commands.', 0
help_mem_detail    db 'mem: Dumps the first 256 bytes of RAM starting from address 0x0000.', 0
help_dump_detail   db 'dump [addr] [count]: Dumps memory starting at addr (hex) for count bytes (default 256).', 0
help_reboot_detail db 'reboot: Restarts the system by jumping to the BIOS reset vector.', 0
help_time_detail   db 'time: Displays the current system time (HH:MM:SS) from the CMOS RTC.', 0
dump_address_msg   db 'Memory dump from address 0x', 0
cpuid_msg  db 'CPU Info:', 0
info_msg1  db 'Welcome to LoxOS 0.2! Thanks for testing', 0
mem_msg    db 'RAM memory size: 0x', 0
temp_buffer times 64 db 0
vendor_msg  db 'Vendor: ', 0
name_msg    db 'CPU Name: ', 0
threads_msg db 'Logical Processors: ', 0
unknown_cores_msg db 'CPU cores: Cannot determine', 0
dump_header db 'Dumping first 256 bytes of memory:', 0
reboot_msg  db 'Rebooting system...', 0
time_msg  db 'System time (HH:MM:SS): ', 0
info_border db '+----------------------------------------+', 0
info_row1   db '| LoxOS 0.3                             |', 0
info_row2   db '| Created by Loxsete                    |', 0
info_row3   db '| Mode: 0x12 graphics                   |', 0
info_row4   db '| Kernel: Mini, 16-bit                  |', 0
info_row5   db '| Commands:                             |', 0
info_row6   db '| help  - show help                     |', 0
info_row7   db '| mem   - show RAM                      |', 0
info_row8   db '| clear - clear screen                  |', 0
info_row9   db '| cpuid - show CPU Info                 |', 0
info_row10 db '| dump or dump XXX - dump memory        |', 0
info_row11 db '| reboot - reboot PC                    |', 0
info_row12 db '| time - time on CMOS                   |', 0

ASCII_art:
    db " ####      #####   ##  ##", 0Dh, 0Ah
    db "  ##      ##   ##  ##  ##", 0Dh, 0Ah
    db "  ##      ##   ##   ####              ####     #####", 0Dh, 0Ah
    db "  ##      ##   ##    ##              ##  ##   ##", 0Dh, 0Ah
    db "  ##   #  ##   ##   ####             ##  ##    #####", 0Dh, 0Ah
    db "  ##  ##  ##   ##  ##  ##            ##  ##        ##", 0Dh, 0Ah
    db " #######   #####   ##  ##             ####    ######", 0Dh, 0Ah
    db 0
cmd_clear   db 'clear', 0
cmd_cpuid   db 'cpuid', 0
cmd_help    db 'help', 0
cmd_info    db 'info', 0
cmd_mem     db 'mem', 0
cmd_dump    db 'dump', 0
cmd_reboot  db 'reboot', 0
cmd_time  db 'time', 0
buffer      times 256 db 0
