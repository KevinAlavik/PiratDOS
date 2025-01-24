; *****************************************************
; PiratDOS V1.0 - Bootstrap Code (Stage 1 Bootloader)
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

BITS    16
ORG     7C00h

; === FAT12 Boot Sector Header ===
JMP_BOOT:                                                   ; Jump to boot code
                            JMP SHORT BOOT                  ;
                            NOP                             ;

OEM_NAME:                   db 'MSWIN4.1'                   ; OEM name
BYTES_PER_SECTOR:           dw 512                          ; Bytes per sector
SECTORS_PER_CLUSTER:        db 1                            ; Sectors per cluster
RESERVED_SECTORS:           dw 1                            ; Reserved sectors
FAT_COUNT:                  db 2                            ; Number of FATs
DIR_ENTRIES:                dw 00E0h                        ; Directory entries
TOTAL_SECTORS:              dw 2880                         ; Total sectors
MEDIA_DESC:                 db 00F0h                        ; Media descriptor
SECTORS_PER_FAT_ENTRY:      dw 9                            ; Sectors per FAT
SECTORS_PER_TRACK:          dw 18                           ; Sectors per track
HEADS:                      dw 2                            ; Number of heads
HIDDEN_SECTORS:             dd 0                            ; Hidden sectors
LARGE_SECTOR_COUNT:         dd 0                            ; Large sector count

; === Extended Boot Record (EBR) ===
DRIVE_NUM:                  db 00h
                            db 00h
SIGNATURE:                  db 29h
VOLUME_ID:                  db 00h, 00h, 00h, 00h
VOLUME_LABEL:               db 'PIRATBOOT  '
SYS_ID:                     db 'FAT12   '

; === PiratDOS V1.0 Bootstrap entry point ===
BOOT:
    ; Setup the data segments
    MOV AX, 00h
    MOV DX, AX
    MOV ES, AX

    ; Setup the stack segment and pointer
    MOV SS, AX
    MOV SP, 7C00h

    ; Make sure we start at 0000:7C00
    PUSH ES
    PUSH WORD .START
    RETF
.START:
    ; Setup video mode to 80x25 text mode
    MOV AH, 00h
    MOV AL, 03h
    INT 10h

    ; Output an 'A' to the display
    MOV AH, 0Eh
    MOV AL, 'A'
    MOV BH, 00h
    MOV BL, 07h
    INT 10h
    JMP $

; === Boot signature and padding ===
TIMES 510-($-$$) db 0
DW 0AA55h