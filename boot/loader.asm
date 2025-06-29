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

.debug_fat:
    MOV AX, [READ_BUFF + 0x1FE]
    CMP AX, 0xAA55
    JNE .invalid_boot_sector

    PRINT "OEM Name: "
    LEA SI, [FAT12(READ_BUFF, oem_name)]
    MOV AX, 8
    CALL PRINTN
    PRINT "\n"

    PRINT "Bytes Per Sector: "
    MOV AX, [FAT12(READ_BUFF, bytes_per_sector)]
    CALL PUTNUM
    PRINT "\n"

    PRINT "Sectors Per Cluster: "
    MOV AL, [FAT12(READ_BUFF, sectors_per_cluster)]
    XOR AH, AH
    CALL PUTNUM
    PRINT "\n"

    PRINT "Reserved Sectors: "
    MOV AX, [FAT12(READ_BUFF, reserved_sectors)]
    CALL PUTNUM
    PRINT "\n"

    PRINT "Number Of FATs: "
    MOV AL, [FAT12(READ_BUFF, num_fats)]
    XOR AH, AH
    CALL PUTNUM
    PRINT "\n"

    PRINT "Dir Entries: "
    MOV AX, [FAT12(READ_BUFF, root_entries)]
    CALL PUTNUM
    PRINT "\n"

    PRINT "Total Sectors: "
    MOV AX, [FAT12(READ_BUFF, total_sectors_16)]
    TEST AX, AX
    JNZ .print_16bit
    PRINT "(32-bit) High: "
    MOV AX, [FAT12(READ_BUFF, total_sectors_32 + 2)]
    CALL PUTNUM
    PRINT ", Low: "
    MOV AX, [FAT12(READ_BUFF, total_sectors_32)]
    CALL PUTNUM
    JMP .next_sectors
.print_16bit:
    CALL PUTNUM
.next_sectors:
    PRINT "\n"
    PRINT "Media Descriptor: 0x"
    MOV AL, [FAT12(READ_BUFF, media_descriptor)]
    XOR AH, AH
    CALL PUTHEX
    PRINT "\n"
    PRINT "Sectors Per FAT: "
    MOV AX, [FAT12(READ_BUFF, sectors_per_fat)]
    CALL PUTNUM
    PRINT "\n"
    PRINT "Sectors Per Track: "
    MOV AX, [FAT12(READ_BUFF, sectors_per_track)]
    CALL PUTNUM
    PRINT "\n"
    PRINT "Heads: "
    MOV AX, [FAT12(READ_BUFF, num_heads)]
    CALL PUTNUM
    PRINT "\n"
    PRINT "Hidden Sectors: "
    MOV AX, [FAT12(READ_BUFF, hidden_sectors)]
    CALL PUTNUM
    PRINT ", High: "
    MOV AX, [FAT12(READ_BUFF, hidden_sectors + 2)]
    CALL PUTNUM
    PRINT "\n"
    PRINT "Volume ID: 0x"
    MOV AX, [FAT12(READ_BUFF, volume_id + 2)]
    CALL PUTHEX
    MOV AX, [FAT12(READ_BUFF, volume_id)]
    CALL PUTHEX
    PRINT "\n"
    PRINT "Volume Label: "
    LEA SI, [FAT12(READ_BUFF, volume_label)]
    MOV AX, 11
    CALL PRINTN
    PRINT "\n"
    JMP HALT
.invalid_boot_sector:
    PRINT "Error: Invalid FAT12 boot sector\n"
    JMP HALT
.finish:
    JMP HALT

; === Data ===
NOTE: DB 'No bootable options available currently.', 0Ah, 0Dh, 0

; Needed for DISK_READ
SECTORS_PER_TRACK      EQU 18  ; Sectors per track from the boot sector
HEADS                  EQU 2   ; Number of heads from the boot sector
DISK_READ_RETRY_COUNT  EQU 10  ; Number of retries for disk read

; Read buffers
READ_BUFF:
