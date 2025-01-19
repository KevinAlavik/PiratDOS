;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pirat DOS v1.0 Alpha      ;
;  - Utility Macros         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%macro println 1
    %assign i 1
    %strlen len %1
    %rep len
        %substr char %1 i 1
        mov al, char
        call putchar
        %assign i i + 1
    %endrep
    mov al, 0x0D
    call putchar
    mov al, 0x0A
    call putchar
%endmacro

%macro print 1
    %assign i 1
    %strlen len %1
    %rep len
        %substr char %1 i 1
        mov al, char
        call putchar
        %assign i i + 1
    %endrep
%endmacro

%macro goto 2
    mov ah, 0x02
    mov bh, 0x00
    mov dh, %2
    mov dl, %1
    int 0x10
%endmacro

%macro set_cursor 1
    %if %1 == 1
        mov ah, 0x01
        mov cx, 0x0607
        int 0x10
    %else
        mov ah, 0x01
        mov cx, 0x2607
        int 0x10
    %endif
%endmacro