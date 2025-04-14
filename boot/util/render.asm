; *****************************************************
; PiratDOS V1.0 - Screen Rendering Utilities
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

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