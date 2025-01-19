;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pirat DOS v1.0 Alpha      ;
;  - Kernel entry point     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ORG     0x1000
BITS    16

start:
    ; Print an 'A' to the screen
    mov ax, 'A'
    mov ah, 0x0E
    mov bh, 0x00
    mov cx, 1
    int 0x10
.halt
    hlt
    jmp .halt