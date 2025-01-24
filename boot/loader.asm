; *****************************************************
; PiratDOS V1.0 - Bootloader Code (Stage 2 Bootloader)
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

BITS    16
ORG     0000h

; === PiratDOS V1.0 Bootloader entry point ===
ENTRY:
    ; Output 'A'
    MOV AH, 0Eh
    MOV AL, 'A'
    MOV BH, 00h
    MOV BL, 07h
    INT 10h
    JMP $