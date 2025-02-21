BITS 16
ORG 0x2000

start:
    push cs
    pop ds

    ; Mensagem de boas-vindas
    mov si, msg_welcome
    call print_string

    ; Solicitar nome do arquivo
    mov di, filename_buffer
    call get_string

    ; Exibir mensagem de edição
    mov si, msg_editing
    call print_string

    ; Ler o arquivo se existir
    call read_file

    ; Iniciar editor
    call edit_file

    ; Retornar ao kernel
    jmp 0x1000

; ============================
; Função: Editar Arquivo
; ============================
edit_file:
    call new_line
    mov si, msg_edit_mode
    call print_string

    mov di, file_content_buffer
    mov cx, 0  ; Contador de caracteres

edit_loop:
    mov ah, 0x00
    int 0x16  ; Espera por tecla pressionada

    cmp al, 0x11  ; Verifica se é CTRL+Q (Sair sem salvar)
    je exit_editor

    cmp al, 0x13  ; Verifica se é CTRL+S (Salvar e sair)
    je save_and_exit

    cmp al, 0x08  ; Backspace
    je handle_backspace

    cmp al, 0x0D  ; Enter (nova linha)
    je handle_newline

    ; Adiciona caractere ao buffer
    mov [di], al
    inc di
    inc cx

    ; Exibir caractere na tela
    mov ah, 0x0E
    int 0x10
    jmp edit_loop

handle_backspace:
    cmp cx, 0
    je edit_loop
    dec di
    dec cx
    mov al, 0x08
    mov ah, 0x0E
    int 0x10  ; Apaga da tela
    mov al, ' '
    int 0x10  ; Substitui com espaço
    mov al, 0x08
    int 0x10  ; Volta o cursor
    jmp edit_loop

handle_newline:
    mov al, 0x0D
    stosb
    mov al, 0x0A
    stosb
    mov ah, 0x0E
    int 0x10
    mov al, 0x0A
    int 0x10
    jmp edit_loop

save_and_exit:
    call save_file
    jmp 0x1000

exit_editor:
    call new_line
    mov si, msg_exit
    call print_string
    jmp 0x1000

; ============================
; Função: Salvar Arquivo
; ============================
save_file:
    call new_line
    mov si, msg_saving
    call print_string

    ; Simulação: Escreve o arquivo no setor 2
    mov ah, 0x03
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0
    mov bx, file_content_buffer
    int 0x13

    call new_line
    mov si, msg_saved
    call print_string
    ret

; ============================
; Função: Ler Arquivo
; ============================
read_file:
    call new_line
    mov si, msg_reading
    call print_string

    ; Simulação: Lê do setor 2 para file_content_buffer
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0
    mov bx, file_content_buffer
    int 0x13

    ; Exibir conteúdo do arquivo
    call new_line
    mov si, file_content_buffer
    call print_string
    ret

; ============================
; Função: Exibir String
; ============================
print_string:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp print_string
done:
    ret

; ============================
; Função: Ler String do Usuário
; ============================
get_string:
    mov cx, 0
read_char:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0D
    je end_input
    mov [di], al
    inc di
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp read_char
end_input:
    mov byte [di], 0
    ret

; ============================
; Função: Nova Linha
; ============================
new_line:
    mov al, 0x0A
    mov ah, 0x0E
    int 0x10
    ret

; ============================
; Mensagens e Buffers
; ============================
msg_welcome db "Editor de Texto - MicroOS", 0
msg_editing db "Editando arquivo...", 0
msg_edit_mode db "Digite seu texto. CTRL+S para salvar, CTRL+Q para sair sem salvar.", 0
msg_saving db "Salvando arquivo...", 0
msg_saved db "Arquivo salvo com sucesso!", 0
msg_exit db "Saindo sem salvar...", 0
msg_reading db "Lendo arquivo...", 0
filename_buffer times 8 db 0
file_content_buffer times 512 db 0
