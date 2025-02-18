BITS 16
ORG 0x7C00  ; Endereço onde a BIOS carrega o bootloader

start:
    ; Configurar modo de vídeo texto 80x25
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Mensagem de carregamento
    mov si, msg_loading
    call print_string

    ; Carregar o kernel para a memória (endereço 0x1000:0000)
    mov ax, 0x1000
    mov es, ax
    mov bx, 0x0000
    mov ah, 0x02
    mov al, 10      ; Número de setores a ler
    mov ch, 0
    mov cl, 2       ; Início do kernel no setor 2
    mov dh, 0       ; Drive 0 (Disco)
    int 0x13
    jc disk_error

    ; Executar o kernel
    jmp 0x1000:0000

disk_error:
    mov si, msg_disk_error
    call print_string
    jmp $

print_string:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp print_string
done:
    ret

msg_loading db "Loading micro-os...", 0
msg_disk_error db "Disk read error!", 0

TIMES 510-($-$$) DB 0
DW 0xAA55  ; Assinatura do setor de boot
