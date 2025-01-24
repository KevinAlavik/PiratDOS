; *****************************************************
; PiratDOS V1.0 - Bootstrap Code (Stage 1 Bootloader)
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

BITS    16
ORG     0x7C00

; === FAT12 Boot Sector Header ===
JMP_BOOT:                                                   ; Jump to boot code
                            JMP SHORT BOOT                  ;
                            NOP                             ;

OEM_NAME:                   db 'MSWIN4.1'                   ; OEM name
BYTES_PER_SECTOR:           dw 512                          ; Bytes per sector
SECTORS_PER_CLUSTER:        db 1                            ; Sectors per cluster
RESERVED_SECTORS:           dw 1                            ; Reserved sectors
FAT_COUNT:                  db 2                            ; Number of FATs
DIR_ENTRIES:                dw 0xE0                         ; Directory entries
TOTAL_SECTORS:              dw 2880                         ; Total sectors
MEDIA_DESC:                 db 0xF0                         ; Media descriptor
SECTORS_PER_FAT_ENTRY:      dw 9                            ; Sectors per FAT
SECTORS_PER_TRACK:          dw 18                           ; Sectors per track
HEADS:                      dw 2                            ; Number of heads
HIDDEN_SECTORS:             dd 0                            ; Hidden sectors
LARGE_SECTOR_COUNT:         dd 0                            ; Large sector count

; === Extended Boot Record (EBR) ===
DRIVE_NUM:                  db 0x00
                            db 0x00
SIGNATURE:                  db 0x29
VOLUME_ID:                  db 0x00, 0x00, 0x00, 0x00
VOLUME_LABEL:               db 'PIRATBOOT  '
SYS_ID:                     db 'FAT12   '

; === PiratDOS V1.0 Bootstrap entry point ===
BOOT:
    ; Setup the data segments
    MOV AX, 0
    MOV DX, AX
    MOV ES, AX

    ; Setup the stack segment and pointer
    MOV SS, AX
    MOV SP, 0x7C00

    ; Make sure we start at 0000:7C00
    PUSH ES
    PUSH WORD .START
    retf
.START:
    ; Setup video mode to 80x25 text mode
    MOV AH, 0x00
    MOV AL, 0x03
    INT 0x10
    JMP $

; === Boot signature and padding ===
TIMES 510-($-$$) db 0
DW 0xAA55