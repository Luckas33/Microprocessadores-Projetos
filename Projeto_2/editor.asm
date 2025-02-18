BITS 16
ORG 0x2000

start:
    mov si, msg_start
    call print_string

editor_loop:
    ; Exibir prompt de edição
    mov si, editor_prompt
    call print_string

    ; Ler comando do usuário
    mov di, editor_command_buffer
    call get_string

    ; Processar comando
    mov si, editor_command_buffer
    cmp byte [si], 'q'  ; Se o comando for "q" (sair do editor)
    je exit_editor

    ; Exibir mensagem de comando desconhecido
    mov si, msg_unknown
    call print_string
    jmp editor_loop

exit_editor:
    jmp 0x1000  ; Retorna ao kernel

print_string:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp print_string
done:
    ret

; Função get_string (copiada do kernel)
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

msg_start db "Simple Text Editor", 0
editor_prompt db "> ", 0
msg_unknown db "Unknown command!", 0
editor_command_buffer times 32 db 0