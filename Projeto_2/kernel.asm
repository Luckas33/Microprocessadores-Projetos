BITS 16
ORG 0x0000

start:
    ; Configurar segmento de dados
    push cs
    pop ds

    ; Configurar modo de vídeo texto
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Exibir mensagem de boas-vindas
    mov si, msg_welcome
    call print_string

main_loop:
    ; Exibir prompt
    mov si, prompt
    call print_string

    ; Ler comando do usuário
    mov di, command_buffer
    call get_string

    ; Processar comando
    cmp byte [command_buffer], 'c'
    je cls_command
    cmp byte [command_buffer], 'r'
    je reboot_command
    cmp byte [command_buffer], 'e'
    je exit_command

    ; Comando desconhecido
    mov si, msg_unknown
    call print_string
    jmp main_loop

cls_command:
    call clear_screen
    jmp main_loop

reboot_command:
    mov ax, 0x0040
    mov ds, ax
    mov word [0x0072], 0x0000
    jmp 0xFFFF:0x0000

exit_command:
    hlt

print_string:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp print_string
done:
    ret

get_string:
    mov ah, 0x00
    int 0x16
    mov [di], al
    ret

clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

msg_welcome db "Welcome to micro-os!", 0
prompt db "> ", 0
msg_unknown db "Unknown command!", 0
command_buffer times 32 db 0
