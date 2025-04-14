; *****************************************************
; PiratDOS V1.0 - Bootloader Code (Stage 2 Bootloader)
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

BITS    16
JMP     ENTRY

; === Includes ===
%INCLUDE "util/render.asm"
%INCLUDE "util/ui.asm"
%INCLUDE "util/error.asm"
%INCLUDE "sys/disk.asm"
%INCLUDE "sys/fat12.asm"

; === PiratDOS V1.0 Bootloader entry point ===
ENTRY:
    ; Disable cursor using dirty hardcoded value
    MOV AH, 0001h
    MOV CX, 2607h
    INT 10h

    ; Render the primary UI
    CALL RNDR_UI

    ; Load FAT12 header from boot sector
    MOV AX, 0                       ; LBA = 0 (Boot sector)
    MOV CL, 1                       ; Read a single sector
    LEA BX, [READ_BUFF]             ; The buffer to store the sector
    CALL DISK_READ
    JC DISK_READ_ERROR

    ; Print out VOLUME_LABEL for debugging
    PRINT "VolumeLabel: "
    LEA SI, [READ_BUFF + FAT12Header.volume_label]
    MOV AX, 11 ; Size of VOLUME_LABEL in a FAT header
    CALL PRINTN

    ; Halt the system, HALT is defined in error.asm
    JMP HALT

; === Data ===
NOTE: DB 'No bootable options available currently.', 0Ah, 0Dh, 0

; Needed for DISK_READ
SECTORS_PER_TRACK      EQU 18  ; Sectors per track from the boot sector
HEADS                  EQU 2   ; Number of heads from the boot sector
DISK_READ_RETRY_COUNT  EQU 10  ; Number of retries for disk read

; Read buffers
READ_BUFF: