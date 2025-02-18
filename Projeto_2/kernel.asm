BITS 16
ORG 0x0000

start:
    ; Configurar segmento de dados
    push cs
    pop ds

    ; Configurar modo de vídeo texto (80x25)
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
    mov si, command_buffer
    cmp byte [si], 'c'
    je cls_command
    cmp byte [si], 'r'
    je reboot_command
    cmp byte [si], 'e'
    je exit_command
    cmp byte [si], 'h'
    je help_command
    cmp byte [si], 'd'
    je editor_command

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
    hlt  ; Para a CPU

help_command:
    mov si, msg_help
    call print_string
    jmp main_loop

editor_command:
    ; Salvar o estado do kernel
    push si
    push di
    push ax

    ; Pular para o código do editor
    jmp 0x2000  ; Endereço onde o editor está localizado

    ; Restaurar o estado do kernel
    pop ax
    pop di
    pop si

print_string:
    lodsb              ; Carrega o próximo caractere de SI
    or al, al          ; Verifica se o caractere é nulo (fim da string)
    jz done
    mov ah, 0x0E       ; Função para imprimir caractere
    int 0x10
    jmp print_string
done:
    ; Após imprimir, faça a quebra de linha
    mov al, 0x0A       ; Caracter LF (Line Feed)
    mov ah, 0x0E       ; Função de impressão do BIOS
    int 0x10           ; Imprime a nova linha
    ret

get_string:
    push si        ; Salvar SI
    push ax        ; Salvar AX
    push bx        ; Salvar BX
    push cx        ; Salvar CX
    
    mov cx, 0      ; Contador de caracteres
    mov si, di     ; SI aponta para o buffer
    
read_char:
    mov ah, 0x00   ; Ler um caractere do teclado
    int 0x16
    
    cmp al, 0x0D   ; Enter pressionado?
    je end_input   ; Se sim, encerra a entrada

    cmp al, 0x08   ; Backspace pressionado?
    je handle_backspace
    
    ; Armazenar caractere no buffer
    mov [si], al
    inc si
    inc cx

    mov ah, 0x0E   ; Exibir o caractere digitado
    int 0x10

    cmp cx, 31     ; Chegou no limite do buffer?
    jl read_char   ; Se não, continua lendo

    jmp end_input  ; Se sim, encerra a entrada

handle_backspace:
    cmp cx, 0      ; Se não há caracteres, ignora o backspace
    je read_char

    dec si
    dec cx

    ; Excluir caractere da tela
    mov ah, 0x0E
    mov al, 0x08   ; Voltar um espaço
    int 0x10
    mov al, ' '    ; Sobrescrever com um espaço
    int 0x10
    mov al, 0x08   ; Voltar um espaço de novo
    int 0x10

    jmp read_char

end_input:
    mov byte [si], 0  ; Adicionar terminador nulo à string

    pop cx        ; Restaurar CX
    pop bx        ; Restaurar BX
    pop ax        ; Restaurar AX
    pop si        ; Restaurar SI
    ret

clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

msg_welcome db "Welcome to micro-os!", 0
msg_help db "Available commands: help, cls, reboot, exit, edit", 0
msg_unknown db "Unknown command!", 0
prompt db "> ", 0
command_buffer times 32 db 0
