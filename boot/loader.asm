; *****************************************************
; PiratDOS V1.0 - Bootloader Code (Stage 2 Bootloader)
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

BITS    16
ORG     0000h

; === PiratDOS V1.0 Bootloader entry point ===
ENTRY:
    LEA SI, [MSG]
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
    MOV AH, 0Eh
.LOOP:
    LODSB
    OR AL, AL
    JZ .DONE
    INT 10h
    JMP .LOOP
.DONE:
    RET


; === Data and options ===
MSG: db 'Hello from the PiratDOS V1.0 Bootloader!', 0Ah, 0Dh, 0