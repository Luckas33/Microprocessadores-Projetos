[BITS 16]  ; Estamos no modo real de 16 bits
[ORG 0x7C00]  ; O BIOS carrega o bootloader neste endereço de memória

start:
    ; Limpa todos os registradores para evitar problemas
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00  ; Define a pilha logo abaixo do bootloader

    ; Configurar modo de vídeo texto (80x25)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Exibir mensagem de boas-vindas
    mov si, msg_welcome
    call print_string

    ; Carregar o kernel para a memória
    mov bx, 0x1000  ; Endereço onde o kernel será carregado
    call load_kernel

    ; Transferir controle para o kernel
    jmp 0x1000  ; Executa o kernel

halt:
    hlt
    jmp halt  ; Entra em loop infinito caso algo dê errado

; ---------------------------------------
; Função: print_string
; Exibe uma string na tela
; ---------------------------------------
print_string:
    lodsb   ; Carrega o próximo caractere em AL
    or al, al
    jz done
    mov ah, 0x0E  ; Função de imprimir caractere
    int 0x10
    jmp print_string
done:
    ret

; ---------------------------------------
; Função: load_kernel
; Carrega o kernel do disco para a memória
; ---------------------------------------
load_kernel:
    mov ah, 0x02    ; Função para ler do disco
    mov al, 10       ; Número de setores para ler (ler 1 setor)
    mov ch, 0       ; Cilindro 0
    mov cl, 2       ; Setor 2 (o primeiro setor após o bootloader)
    mov dh, 0       ; Cabeça 0
    mov dl, 0x80    ; Primeiro disco rígido
    int 0x13        ; Chama a interrupção de leitura do disco
    jc disk_error   ; Se falhar, pula para erro
    ret

disk_error:
    mov si, msg_error
    call print_string
    jmp halt

; ---------------------------------------
; Mensagens
; ---------------------------------------
msg_welcome db "Welcome to micro-os!", 0
msg_error db "Disk read error!", 0
; Preenche até 512 bytes e define assinatura do bootloader
times 510-($-$$) db 0
dw 0xAA55  ; Assinatura obrigatória para ser reconhecido pelo BIOS