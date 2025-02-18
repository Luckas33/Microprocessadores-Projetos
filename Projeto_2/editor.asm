BITS 16
ORG 0x2000

start:
    mov si, msg_start
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

msg_start db "Simple Text Editor", 0
