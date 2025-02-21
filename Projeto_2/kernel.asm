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

    ; Comparação para comando 'ls'
    mov di, msg_ls_command
    call compare_strings
    je ls_command

    ; Comparação para comando 'echo'
    mov di, msg_echo_command
    call compare_strings
    je echo_command

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
    ; Loop infinito para "travar" o sistema
    jmp $

ls_command:
    call list_files
    jmp main_loop

echo_command:
    call new_line
    ; Extrair nome do arquivo e conteúdo
    mov si, command_buffer + 5  ; Pula "echo "
    mov di, filename_buffer
    call extract_filename
    mov si, command_buffer + 5
    call skip_spaces
    mov di, file_content_buffer
    call extract_content

    ; Criar arquivo
    call create_file
    jmp main_loop

edit_command:
    call new_line
    ; Extrair nome do arquivo
    mov si, command_buffer + 5  ; Pula "edit "
    mov di, filename_buffer
    call extract_filename

    ; Verificar se o arquivo existe
    call find_file
    jc file_not_found_func

    ; Abrir editor
    call open_editor
    jmp main_loop

file_not_found_func:
    mov si, msg_file_not_found
    call print_string
    jmp main_loop

; Função para abrir o editor
open_editor:
    ; Exibir conteúdo do arquivo
    mov si, file_content_buffer
    call print_string
    call new_line

editor_loop:
    ; Ler entrada do usuário
    mov ah, 0x00
    int 0x16

    ; Verificar atalhos
    cmp al, 0x13  ; Ctrl+S (Salvar)
    je save_file
    cmp al, 0x11  ; Ctrl+Q (Sair)
    je close_editor

    ; Adicionar caractere ao buffer
    mov [si], al
    inc si
    mov ah, 0x0E
    int 0x10
    jmp editor_loop

save_file:
    call new_line
    mov si, msg_saved
    call print_string
    ret

close_editor:
    call new_line
    ret

; Função para listar arquivos
list_files:
    mov si, file_table
    mov cl, [file_count]
    cmp cl, 0
    je no_files

list_loop:
    mov di, si
    call print_string
    call new_line
    add si, filename_length + file_content_length
    loop list_loop
    ret

no_files:
    mov si, msg_no_files
    call print_string
    ret

; Função para criar um arquivo
create_file:
    mov si, filename_buffer
    mov di, file_table
    mov cl, [file_count]
    cmp cl, max_files
    jge too_many_files

    ; Copiar nome do arquivo
    mov cx, filename_length
    rep movsb

    ; Copiar conteúdo do arquivo
    mov si, file_content_buffer
    mov cx, file_content_length
    rep movsb

    ; Incrementar contador de arquivos
    inc byte [file_count]
    ret

too_many_files:
    mov si, msg_too_many_files
    call print_string
    ret

; Função para encontrar um arquivo
find_file:
    mov si, filename_buffer
    mov di, file_table
    mov cl, [file_count]
    cmp cl, 0
    je file_not_found_message

find_loop:
    push si
    push di
    mov cx, filename_length
    repe cmpsb
    pop di
    pop si
    je file_found

    add di, filename_length + file_content_length
    loop find_loop

file_not_found_message:
    mov si, msg_file_not_found
    call print_string
    ret

file_found:
    ret

; Funções auxiliares
extract_filename:
    ; Copia o nome do arquivo até o primeiro espaço
    mov cx, filename_length
extract_loop:
    lodsb
    cmp al, ' '
    je extract_done
    stosb
    loop extract_loop
extract_done:
    ret

extract_content:
    ; Copia o conteúdo após o nome do arquivo
    mov cx, file_content_length
extract_content_loop:
    lodsb
    cmp al, 0
    je extract_content_done
    stosb
    loop extract_content_loop
extract_content_done:
    ret

skip_spaces:
    ; Pula espaços em branco
skip_loop:
    lodsb
    cmp al, ' '
    je skip_loop
    dec si
    ret

; Função para imprimir strings
print_string:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp print_string
done:
    ret

; Função para adicionar nova linha
new_line:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
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
    push si
    push ax
    push bx
    push cx
    
    mov cx, 0
    mov si, di
    
read_char:
    mov ah, 0x00
    int 0x16
    
    cmp al, 0x0D
    je end_input

    cmp al, 0x08
    je handle_backspace
    
    mov [si], al
    inc si
    inc cx

    mov ah, 0x0E
    int 0x10

    cmp cx, 31
    jl read_char

    jmp end_input

handle_backspace:
    cmp cx, 0
    je read_char

    dec si
    dec cx

    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10

    jmp read_char

end_input:
    mov byte [si], 0

    pop cx
    pop bx
    pop ax
    pop si
    ret

; Função para comparar strings
compare_strings:
    push ax
    push bx
    push cx
    push dx

compare_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne not_equal
    inc si
    inc di
    cmp al, 0
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

; Estrutura de dados para armazenar arquivos
max_files equ 10
filename_length equ 12
file_content_length equ 512

file_table:
    times max_files * (filename_length + file_content_length) db 0
file_count db 0

; Mensagens para o sistema
msg_welcome db "Bem-vindo ao micro-os!", 0
msg_help db "Comandos disponíveis: help, cls, reboot, exit, ls, echo, edit", 0
msg_unknown db "Comando desconhecido!", 0
msg_enter_filename db "Digite o nome do arquivo: ", 0
msg_editing db "Editando... Pressione Ctrl+S para salvar ou Ctrl+Q para sair.", 0
msg_saved db "Arquivo salvo!", 0
msg_file_not_found db "Arquivo não encontrado.", 0
msg_too_many_files db "Limite de arquivos atingido.", 0
msg_no_files db "Nenhum arquivo encontrado.", 0
prompt db "> ", 0
command_buffer times 32 db 0
file_content_buffer times 512 db 0
filename_buffer times 12 db 0

; Comandos para comparação
msg_help_command db "help", 0
msg_cls_command db "cls", 0
msg_reboot_command db "reboot", 0
msg_exit_command db "exit", 0
msg_ls_command db "ls", 0
msg_echo_command db "echo", 0
msg_edit_command db "edit", 0
