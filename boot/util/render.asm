; *****************************************************
; PiratDOS V1.0 - Screen Rendering Utilities
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

%IFNDEF RENDER_ASM
%DEFINE RENDER_ASM

; === Print Functions ===
; *******************
; PRINTZ: Outputs an NULL-terminated string to the display
; Arguments:
;   - DS:SI - Pointer to the string to output
; *******************
PRINTZ:
    PUSHA
    MOV AH, 0Eh
.LOOP:
    LODSB
    OR AL, AL
    JZ .DONE
    INT 10h
    JMP .LOOP
.DONE:
    POPA
    RET

; *******************
; PRINTN: Outputs BYTES of string to the display
; Arguments:
;   - DS:SI - Pointer to the string to output
;   - AX - Ammount of bytes to write
; *******************
PRINTN:
    PUSHA
    MOV CX, AX
    MOV AH, 0Eh
.LOOP:
    JCXZ .DONE
    LODSB
    INT 10h
    LOOP .LOOP
.DONE:
    POPA
    RET

; *******************
; PUTNUM: Outputs an unsigned integer as a string of digits
; Arguments:
;   - AX - The integer to output (16-bit value)
PUTNUM:
    PUSHA
    MOV BX, 10         ; Divisor for base 10
    MOV CX, 0          ; Clear CX (will hold the number of digits)
    MOV DX, 0          ; Clear DX (will hold remainder)

    ; Check if number is 0
    TEST AX, AX
    JZ .ZERO

    ; Convert the number to ASCII digits in reverse order
.REVERSE_LOOP:
    XOR DX, DX         ; Clear DX (remainder storage)
    DIV BX             ; AX = AX / 10, DX = AX % 10
    ADD DL, '0'        ; Convert remainder to ASCII
    PUSH DX            ; Save the digit
    INC CX             ; Increment digit count
    TEST AX, AX
    JNZ .REVERSE_LOOP

.DONE:
    ; Output digits in reverse order
    MOV AH, 0Eh
.PRINT_LOOP:
    POP DX             ; Retrieve digit from stack
    MOV AL, DL         ; Move digit to AL
    INT 10h            ; Output the digit
    LOOP .PRINT_LOOP

    POPA
    RET

.ZERO:
    ; Special case for zero
    MOV AL, '0'        ; ASCII for '0'
    MOV AH, 0Eh
    INT 10h            ; Output '0'
    POPA
    RET


; === Utility Macros ===
; *******************
; (MACRO) GOTO: Places the mouse at (x,y)
; Arguments: X, Y
; *******************
%MACRO GOTO 2
    MOV AH, 02h
    MOV BH, 00h
    MOV DL, %1       ; X
    MOV DH, %2       ; Y
    INT 10h
%ENDMACRO

%ENDIF ; RENDER_ASM