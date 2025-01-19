;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pirat DOS v1.0 Alpha      ;
;  - Utility Macros         ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%macro println 1
    ; Save registers
    push ax
    push bx
    push cx
    push dx

    %assign i 1
    %strlen len %1
    %rep len
        %substr char %1 i 1
        mov al, char
        call putchar
        %assign i i + 1
    %endrep
    mov al, 0x0D  ; Carriage return
    call putchar
    mov al, 0x0A  ; Line feed
    call putchar

    ; Restore registers
    pop dx
    pop cx
    pop bx
    pop ax
%endmacro

%macro print 1
    ; Save registers
    push ax
    push bx
    push cx
    push dx

    %assign i 1
    %strlen len %1
    %rep len
        %substr char %1 i 1
        mov al, char
        call putchar
        %assign i i + 1
    %endrep

    ; Restore registers
    pop dx
    pop cx
    pop bx
    pop ax
%endmacro

%macro _printnum 1
    ; Save registers
    push ax
    push bx
    push cx
    push dx

    ; Load the number into AX
    mov ax, %1

    ; If AX == 0, print '0' and return
    cmp ax, 0
    jne .convert_number
    mov al, '0'
    call putchar
    jmp .done
.convert_number:
    ; Initialize variables
    xor cx, cx              ; Clear CX (digit count)
    mov bx, 10              ; Divisor for decimal conversion
.store_digits:
    xor dx, dx              ; Clear DX (remainder)
    div bx                  ; AX = AX / 10, DX = remainder
    push dx                 ; Store the remainder (digit) on the stack
    inc cx                  ; Increment digit count
    test ax, ax             ; Check if AX is 0
    jnz .store_digits       ; Repeat if AX != 0
.print_digits:
    pop dx                  ; Retrieve digit from the stack
    add dl, '0'             ; Convert to ASCII
    mov al, dl              ; Move to AL for putchar
    call putchar            ; Print the character
    loop .print_digits      ; Repeat for all stored digits
.done:
    ; Restore registers
    pop dx
    pop cx
    pop bx
    pop ax
%endmacro

; printreg(name, reg)
%macro printreg 2
    print %1
    print ": "
    _printnum %2
    println ""
%endmacro

%macro set_cursor 1
    ; Save registers
    push ax
    push bx
    push cx
    push dx

    %if %1 == 1
        mov ah, 0x01
        mov cx, 0x0607
        int 0x10
    %else
        mov ah, 0x01
        mov cx, 0x2607
        int 0x10
    %endif

    ; Restore registers
    pop dx
    pop cx
    pop bx
    pop ax
%endmacro

%macro get_key 1
    ; Save registers
    push ax
    push bx
    push cx
    push dx

    mov ah, 0x00
    int 0x16
    mov %1, al

    ; Restore registers
    pop dx
    pop cx
    pop bx
    pop ax
%endmacro

%macro clear_screen 0
    ; Save registers
    push ax
    push bx
    push cx
    push dx

    mov ah, 0x02
    mov al, 0x00
    mov cx, 0x1320
    mov dx, 0x00
    int 0x10

    ; Restore registers
    pop dx
    pop cx
    pop bx
    pop ax
%endmacro

%macro goto 2
    ; Save registers
    push ax
    push bx
    push cx
    push dx

    mov ah, 0x02
    mov bh, 0x00
    mov dh, %2
    mov dl, %1
    int 0x10

    ; Restore registers
    pop dx
    pop cx
    pop bx
    pop ax
%endmacro
