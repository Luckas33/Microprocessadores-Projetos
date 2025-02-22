BITS 16
ORG 0x1000

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
    call new_line         ; Adiciona a quebra de linha antes de exibir o prompt
    ; Exibir prompt
    mov si, prompt
    call print_string

    ; Limpar buffer de comando antes de ler uma nova entrada
    mov si, command_buffer
    mov cx, 32
clear_buffer:
    mov byte [si], 0
    inc si
    loop clear_buffer

    ; Ler comando do usuário
    mov di, command_buffer
    call get_string

    ; Processar comando
    mov si, command_buffer
    ; Comparação para comando 'help'
    mov di, msg_help_command
    call compare_strings
    je help_command

    ; Comparação para comando 'cls'
    mov di, msg_cls_command
    call compare_strings
    je cls_command

    ; Comparação para comando 'reboot'
    mov di, msg_reboot_command
    call compare_strings
    je reboot_command

    ; Comparação para comando 'exit'
    mov di, msg_exit_command
    call compare_strings
    je exit_command

    ; Comparação para comando 'edit'
    mov di, msg_edit_command
    call compare_strings
    je edit_command

    ; Comando desconhecido
    mov si, msg_unknown
    call print_string
    jmp main_loop

help_command:
    call new_line         ; Adiciona a quebra de linha antes da resposta
    mov si, msg_help
    call print_string
    jmp main_loop

cls_command:
    call clear_screen
    jmp main_loop

reboot_command:
    call new_line         ; Adiciona quebra de linha antes de reiniciar
    mov ax, 0x0040
    mov ds, ax
    mov word [0x0072], 0x0000
    jmp 0xFFFF:0x0000

exit_command:
    call new_line
    hlt  ; Para a CPU

edit_command:
    call new_line
    mov si, msg_enter_filename
    call print_string

    mov di, filename_buffer
    call get_string

    ; Iniciar modo de edição
    call edit_file
    jmp main_loop

edit_file:
    call new_line
    mov si, msg_editing
    call print_string

    ; Loop de edição
edit_loop:
    ; Ler caractere do teclado
    mov ah, 0x00
    int 0x16

    ; Verificar se a tecla ; foi pressionada (salvar)
    cmp al, 0x3B  ; 0x3B é o código ASCII para ;
    je save_file

    ; Verificar se a tecla [ foi pressionada (sair)
    cmp al, 0x5B  ; 0x5B é o código ASCII para [
    je end_edit

    ; Verificar se a tecla Backspace foi pressionada
    cmp al, 0x08  ; 0x08 é o código ASCII para Backspace
    je handle_backspace_edit

    ; Verificar se a tecla Enter foi pressionada
    cmp al, 0x0D  ; 0x0D é o código ASCII para Enter
    je handle_enter

    ; Exibir o caractere digitado
    mov ah, 0x0E
    int 0x10

    ; Armazenar caractere no buffer de conteúdo
    mov [di], al
    inc di

    ; Continuar no loop
    jmp edit_loop

handle_enter:
    ; Pular linha no editor
    call new_line
    ; Adicionar uma nova linha no buffer
    mov byte [di], 0x0D  ; Carriage Return
    inc di
    mov byte [di], 0x0A  ; Line Feed
    inc di
    jmp edit_loop

handle_backspace_edit:
    ; Verificar se há caracteres para apagar
    cmp di, file_content_buffer
    jbe edit_loop  ; Se não há caracteres, ignorar

    ; Apagar o último caractere do buffer
    dec di
    mov byte [di], 0

    ; Apagar o caractere da tela
    mov ah, 0x0E
    mov al, 0x08  ; Backspace
    int 0x10
    mov al, ' '   ; Sobrescrever com espaço
    int 0x10
    mov al, 0x08  ; Voltar novamente
    int 0x10

    jmp edit_loop

save_file:
    call new_line
    mov si, msg_saved
    call print_string
    ret

end_edit:
    call new_line
    mov si, msg_edit_exit
    call print_string
    ret

; Função para imprimir strings e adicionar quebra de linha ao final
print_string:
    lodsb              ; Carrega o próximo caractere de SI
    or al, al          ; Verifica se o caractere é nulo (fim da string)
    jz done
    mov ah, 0x0E       ; Função para imprimir caractere
    int 0x10
    jmp print_string
done:
    ret


new_line:
    mov ah, 0x0E
    mov al, 0x0D       ; Carriage Return (Volta ao início da linha)
    int 0x10
    mov al, 0x0A       ; Line Feed (Move para a linha de baixo)
    int 0x10
    ret

; Função para limpar a tela
clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

; Função para ler uma string do teclado
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

; Função para comparar duas strings
compare_strings:
    push ax
    push bx
    push cx
    push dx

compare_loop:
    mov al, [si]      ; Carrega o caractere de si (comando do usuário)
    mov bl, [di]      ; Carrega o caractere de di (comando esperado)
    cmp al, bl        ; Compara os caracteres
    jne not_equal     ; Se diferentes, vai para not_equal
    inc si
    inc di
    cmp al, 0         ; Verifica se chegou ao final da string
    je strings_equal
    jmp compare_loop

not_equal:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

strings_equal:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Mensagens para o sistema
msg_welcome db "Bem-vindo ao micro-os!", 0
msg_help db "Comandos disponíveis: help, cls, reboot, sair, editar", 0
msg_unknown db "Comando desconhecido!", 0
msg_enter_filename db "Digite o nome do arquivo: ", 0
msg_editing db "Editando... Pressione ; para salvar, [ para sair, Backspace para apagar.", 0
msg_saved db "Arquivo salvo!", 0
msg_edit_exit db "Saindo do modo de edição.", 0
prompt db "> ", 0
command_buffer times 32 db 0
file_content_buffer times 512 db 0  ; Buffer para o conteúdo do arquivo
filename_buffer times 12 db 0       ; Buffer para o nome do arquivo

; Comandos para comparação
msg_help_command db "help", 0
msg_cls_command db "cls", 0
msg_reboot_command db "reboot", 0
msg_exit_command db "sair", 0
msg_edit_command db "editar", 0