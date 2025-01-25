; *****************************************************
; PiratDOS V1.0 - Bootloader Code (Stage 2 Bootloader)
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

BITS    16
ORG     0000h

; === PiratDOS V1.0 Bootloader entry point ===
ENTRY:
    CALL RNDR_UI
    LEA SI, [NOTE]
    CALL PRINTZ
.HALT:
    HALT
    JMP $

; === Utility Functions ===
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
; (MACRO) GOTO: Places the mouse at (x,y)
; Arguments: X, Y
; *******************
%macro GOTO 2
    MOV AH, 02h
    MOV BH, 00h
    MOV DL, %1       ; X
    MOV DH, %2       ; Y
    INT 10h
%endmacro

; *******************
; RNDR_UI: Renders the User Interface
; Arguments: None
; *******************
RNDR_UI:
    PUSHA
    GOTO 0, 23
    LEA SI, [SEPERATOR]
    CALL PRINTZ
    GOTO 0, 24
    LEA SI, [BOTTOM_BAR]
    CALL PRINTZ
    GOTO 0, 0
    POPA
    RET

; === Data and options ===
; *** UI ELEMENTS ***
BOTTOM_BAR: 
    DB 'PiratDOS v1.0 Alpha - Copyright (c) Kevin Alavik 2025'
    TIMES 14 DB '.'
    DB '(Bootloader)', 0
SEPERATOR:
    %rep 40
    DB '-'
    DB '*'
    %endrep
    DB 0
NOTE: DB 'No bootable options available currently.', 0Ah, 0Dh, 0