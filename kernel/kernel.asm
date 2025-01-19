;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pirat DOS v1.0 Alpha      ;
;  - Kernel entry point     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BITS    16

; --------------------- ;
;  Kernel Entry         ;
; --------------------- ;
start:
    mov ax, 'A'
    call putchar

    mov si, boot_msg
    call puts
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
    push si
    push ax
    push bx
.loop:
    lodsb
    or al, al
    jz .done
    call putchar
    jmp .loop
.done:
    pop bx
    pop ax
    pop si    
    ret

; Prints a single character to the screen, page number 0.
; Arguments:
;   - al: Character to print
;   - bl: Attribute for the character
putchar:
    push ax
    push bx
    push cx

    mov ah, 0x0E
    mov bh, 0x00
    mov cx, 1
    int 0x10

    pop cx
    pop bx
    pop ax
    ret

; --------------------- ;
;  Data                 ;
; --------------------- ;
boot_msg: db 'PiratDOS V1.0 Alpha', 0xA, 0xD, 0
