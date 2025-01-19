;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pirat DOS v1.0 Alpha      ;
;  - Kernel entry point     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BITS 16

%include "utils.inc"

; --------------------- ;
;  Kernel Entry         ;
; --------------------- ;
init:
    set_cursor 0
    goto 0, 23
    %rep 80
        print "-"
    %endrep
    print "PiratDOS v1.0 Alpha - Copyright (c) Kevin Alavik 2025"
    goto 0, 0
    call start
.halt:
    hlt
    jmp .halt

start:
    println ":)"
    ret

; --------------------- ;
;  Utility Functions    ;
; --------------------- ;

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
