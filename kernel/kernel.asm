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
    call render_screen
    println "Insert program floppy and press ENTER..."
.loop:
    ; Wait for keypress
    mov ah, 0
    int 16h
    cmp al, 13                  ; Check if ASCII code of Enter key (13) was pressed
    je load_prgm_disk          ; Continue with loading the program disk
    jne .loop

; --------------------- ;
;  Program Disk Loading ;
; --------------------- ;
load_prgm_disk:
    mov dl, 0x01         ; DL: 0x01 = 2nd floppy drive
    mov ah, 0x00
    int 0x13

    cmp ah, 0
    je .disk_found
    
    error "0xA002", "Failed to load disk 2."
    jmp $
.disk_found:
    println "Loading program disk..."
    error "0xA001", "Program disk loading is unimplemented"
    jmp $
    

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

; Renders the screen.
render_screen:
    clear_screen
    set_cursor 0
    goto 0, 23
    %rep 80
        print "-"
    %endrep
    print "PiratDOS v1.0 Alpha - Copyright (c) Kevin Alavik 2025"
    goto 0, 0
    ret