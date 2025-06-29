; *****************************************************
; PiratDOS V1.0 - Screen Rendering Utilities
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

%IFNDEF RENDER_ASM
%DEFINE RENDER_ASM

; === Print Functions ===
; *******************
; PRINTZ: Outputs a NULL-terminated string to the display
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
;   - AX - Amount of bytes to write
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
; *******************
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

; *******************
; PUTCHAR: Outputs a single character to the display
; Arguments:
;   - AL - The character to output
; *******************
PUTCHAR:
    PUSHA
    MOV AH, 0Eh        ; BIOS teletype output
    MOV BH, 0          ; Page 0
    MOV BL, 07h        ; White on black
    INT 10h            ; Output character in AL
    POPA
    RET

; *******************
; PUTHEX: Outputs a 16-bit value as a 4-digit hexadecimal number
; Arguments:
;   - AX - The 16-bit value to output
; *******************
PUTHEX:
    PUSHA
    MOV BX, AX         ; Save value
    MOV CX, 4          ; 4 nibbles in 16-bit value
.PUTHEX_LOOP:
    ROL BX, 4          ; Get next nibble
    MOV AL, BL
    AND AL, 0x0F       ; Isolate nibble
    CMP AL, 10
    JB .DIGIT
    ADD AL, 'A' - 10   ; Convert 10-15 to A-F
    JMP .PRINT
.DIGIT:
    ADD AL, '0'        ; Convert 0-9 to '0'-'9'
.PRINT:
    CALL PUTCHAR       ; Print character in AL
    LOOP .PUTHEX_LOOP
    POPA
    RET

; === Utility Macros ===
; *******************
; (MACRO) GOTO: Places the cursor at (x,y)
; Arguments: X, Y
; *******************
%MACRO GOTO 2
    MOV AH, 02h
    MOV BH, 00h
    MOV DL, %1       ; X
    MOV DH, %2       ; Y
    INT 10h
%ENDMACRO

; *******************
; (MACRO) PRINT: Outputs a string directly to the screen
; Arguments: The string to output
; *******************
%MACRO PRINT 1
    %ASSIGN I 1
    %STRLEN LEN %1
    %REP LEN
        %SUBSTR CHAR %1 I 1
        %IF CHAR == 0
            ; Don't emit anything for null characters
        %ELSE
            %SUBSTR NEXT_CHAR %1 I+1 1
            %IF CHAR == 5Ch ; '\'
                %IF NEXT_CHAR == 6Eh ; 'n'
                    ; Handle \n as newline
                    MOV AH, 0Eh
                    MOV AL, 0Dh  ; Carriage Return
                    INT 10h
                    MOV AL, 0Ah  ; Line Feed
                    INT 10h
                    %ASSIGN I I + 2
                %ELSE
                    ; Print backslash and next char literally
                    MOV AH, 0Eh
                    MOV AL, 5Ch  ; '\'
                    INT 10h
                    %IF NEXT_CHAR != 0
                        MOV AL, NEXT_CHAR
                        INT 10h
                        %ASSIGN I I + 2
                    %ELSE
                        ; No next character, just move by 1
                        %ASSIGN I I + 1
                    %ENDIF
                %ENDIF
            %ELSE
                ; Print normal char
                MOV AH, 0Eh
                MOV AL, CHAR
                INT 10h
                %ASSIGN I I + 1
            %ENDIF
        %ENDIF
    %ENDREP
%ENDMACRO

%ENDIF ; RENDER_ASM
