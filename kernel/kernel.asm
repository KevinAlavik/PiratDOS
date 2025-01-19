;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pirat DOS v1.0 Alpha      ;
;  - Kernel entry point     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BITS    16

; --------------------- ;
;  Kernel Entry         ;
; --------------------- ;
start:
    cli
    xor ax, ax
    mov ds, ax
    mov si, boot_msg
    call puts
    mov ah, 0x0E
    mov al, 'A'
    mov bh, 0x00
    int 0x10
.halt
    hlt
    jmp .halt

; --------------------- ;
;  Utility Functions    ;
; --------------------- ;

; Prints a string to the screen, page number 0.
; Arguments:
;   - ds:si, String pointer
puts:
    pusha
.loop:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp .loop
.done:
    popa
    ret

; --------------------- ;
;  Data                 ;
; --------------------- ;
boot_msg: db 'PiratDOS V1.0 Alpha', 0x0A, 0x0D, 0
