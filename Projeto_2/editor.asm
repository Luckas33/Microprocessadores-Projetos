BITS 16
ORG 0x2000

start:
    ; Configurar segmento de dados
    push cs
    pop ds

    ; Exibir mensagem inicial
    mov si, msg_welcome
    call print_string

main_loop:
    ; Exibir prompt
    mov si, prompt
    call print_string

    ; Limpar buffer de comando antes de ler nova entrada
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
    cmp byte [si], 'l'       ; Se "l" -> listar arquivos
    je list_command

    cmp byte [si], 'w'       ; Se "w" -> escrever arquivo
    je write_command

    cmp byte [si], 'r'       ; Se "r" -> ler arquivo
    je read_command

    cmp byte [si], 'e'       ; Se "e" -> sair
    je exit_command

    ; Comando desconhecido
    mov si, msg_unknown
    call print_string
    jmp main_loop

list_command:
    call list_files
    jmp main_loop

write_command:
    call write_file
    jmp main_loop

read_command:
    call read_file
    jmp main_loop

exit_command:
    hlt  ; Para a CPU

; ==========================================================
; Função: Lista os arquivos armazenados no disco
; ==========================================================
list_files:
    mov si, msg_list_files
    call print_string

    mov bx, 0x0201         ; BIOS função 02h (ler setor), drive 0 (floppy)
    mov dx, 0x0001         ; Setor 1 (Tabela de Arquivos)
    mov cx, 1
    mov ax, 0x0201
    int 0x13               ; Lê tabela de arquivos para ES:BX

    mov di, 0x1000         ; Buffer da tabela de arquivos
list_loop:
    cmp byte [di], 0       ; Verifica se o nome é vazio (fim da lista)
    je list_done
    mov si, di             ; Nome do arquivo
    call print_string
    call new_line
    add di, 12             ; Pula para próxima entrada
    jmp list_loop
list_done:
    ret

; ==========================================================
; Função: Escreve um arquivo no disco
; ==========================================================
write_file:
    mov si, msg_enter_filename
    call print_string

    mov di, filename_buffer
    call get_string         ; Lê nome do arquivo

    mov si, msg_enter_content
    call print_string

    mov di, file_content_buffer
    call get_string         ; Lê conteúdo do arquivo

    ; Determinar setor disponível
    mov ax, 2               ; Setor inicial (começa no setor 2)
    mov bx, 1               ; Tamanho em setores (1 setor)

    ; Escrever entrada na tabela de arquivos
    mov si, filename_buffer
    mov di, 0x1000          ; Posição na tabela
    mov cx, 8
copy_filename:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    loop copy_filename

    mov [di], ax            ; Setor inicial
    add di, 2
    mov [di], bx            ; Tamanho do arquivo
    add di, 2

    ; Escrever arquivo no disco
    mov ah, 0x03
    mov al, 1
    mov ch, 0
    mov cl, 2               ; Setor 2 (onde será salvo)
    mov dh, 0
    mov dl, 0
    mov bx, file_content_buffer
    int 0x13

    ret

; ==========================================================
; Função: Lê um arquivo do disco
; ==========================================================
read_file:
    mov si, msg_enter_filename
    call print_string

    mov di, filename_buffer
    call get_string         ; Lê nome do arquivo

    ; Procurar na tabela de arquivos
    mov di, 0x1000
search_file:
    mov si, filename_buffer
    mov cx, 8
    repe cmpsb
    je file_found           ; Se encontrou, pula para ler os dados
    add di, 12
    cmp byte [di], 0
    jne search_file
    mov si, msg_file_not_found
    call print_string
    ret

file_found:
    mov ax, [di]            ; Setor inicial
    add di, 2
    mov bx, [di]            ; Tamanho em setores

    ; Ler conteúdo do disco
    mov ah, 0x02
    mov al, bl
    mov ch, 0
    mov cl, al
    mov dh, 0
    mov dl, 0
    mov bx, file_content_buffer
    int 0x13

    ; Exibir conteúdo do arquivo
    mov si, file_content_buffer
    call print_string
    ret

; ==========================================================
; Funções auxiliares
; ==========================================================
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

new_line:
    mov al, 0x0A
    mov ah, 0x0E
    int 0x10
    ret

; ==========================================================
; Variáveis
; ==========================================================
msg_welcome db "Welcome to micro-os!", 0
msg_list_files db "Files:", 0
msg_enter_filename db "Enter filename: ", 0
msg_enter_content db "Enter content: ", 0
msg_file_not_found db "File not found!", 0
msg_unknown db "Unknown command!", 0
prompt db "> ", 0
filename_buffer times 8 db 0
file_content_buffer times 512 db 0
command_buffer times 32 db 0
