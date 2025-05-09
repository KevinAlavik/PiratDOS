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

OEM_NAME:                   DB 'MSWIN4.1'                   ; OEM name
BYTES_PER_SECTOR:           DW 512                          ; Bytes per sector
SECTORS_PER_CLUSTER:        DB 1                            ; Sectors per cluster
RESERVED_SECTORS:           DW 1                            ; Reserved sectors
FAT_COUNT:                  DB 2                            ; Number of FATs
DIR_ENTRIES:                DW 00E0h                        ; Directory entries
TOTAL_SECTORS:              DW 2880                         ; Total sectors
MEDIA_DESC:                 DB 00F0h                        ; Media descriptor
SECTORS_PER_FAT_ENTRY:      DW 9                            ; Sectors per FAT
SECTORS_PER_TRACK:          DW 18                           ; Sectors per track
HEADS:                      DW 2                            ; Number of heads
HIDDEN_SECTORS:             DD 0                            ; Hidden sectors
LARGE_SECTOR_COUNT:         DD 0                            ; Large sector count

; === Extended Boot Record (EBR) ===
DRIVE_NUM:                  DB 00h
                            DB 00h
SIGNATURE:                  DB 29h
VOLUME_ID:                  DB 00h, 00h, 00h, 00h
VOLUME_LABEL:               DB 'PIRATBOOT  '
SYS_ID:                     DB 'FAT12   '

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
    ; Save the boot drive number
    MOV [DRIVE_NUM], DL

    ; Output the boot message to the display using PRINTZ
    LEA SI, [BOOT_MSG]
    CALL PRINTZ

    ; Read driver information
    PUSH ES
    MOV AH, 08h
    MOV DL, [DRIVE_NUM]
    INT 13h
    JC READ_ERR
    POP ES

    AND CL, 3Fh
    XOR CH, CH
    MOV [SECTORS_PER_TRACK], CX

    INC DH
    MOV [HEADS], DH

    ; Calculate the LBA of root dir, ROOT = RESERVED + FATS * SECTORS_PER_FAT
    MOV AX, [SECTORS_PER_FAT_ENTRY]
    MOV BL, [FAT_COUNT]
    XOR BH, BH
    MUL BX                              ; AX = (FATS * SECTORS_PER_FAT)
    ADD AX, [RESERVED_SECTORS]          ; AX = LBA
    PUSH AX                             ; Store LBA on stack

    ; Calculate the size of the root dir, SIZE = (32 * NUMBER_OF_ENTRIES) / BYTES_PER_SECTOR
    MOV AX, [DIR_ENTRIES]
    SHL AX, 5                           ; AX *= 32
    XOR DX, DX                          ; Zero out DX
    DIV WORD [BYTES_PER_SECTOR]         ; Sectors to read
    TEST DX, DX                         ; If DX != 0 aDD 1
    JZ .ROOT_AFTER
    INC AX
.ROOT_AFTER:
    ; Read root directory
    MOV CL, AL                          ; CL = SECTORS TO READ = SIZE OF ROOT
    POP AX                              ; AX = LBA
    MOV DL, [DRIVE_NUM]                 ; Our boot drive
    MOV BX, LOADER_BUFFER               ; ES:BX = Loader Buffer
    CALL DISK_READ
    JC READ_ERR

    ; Search for LOADER.SYS
    XOR BX, BX
    MOV DI, LOADER_BUFFER
.SEARCH:
    MOV SI, LOADER_FILE
    MOV CX, 11                          ; Compare up-to 11 characters.
    PUSH DI
    REPE CMPSB
    POP DI
    JE .FOUND
    ADD DI, 32                          ; Move to next directory entry
    INC BX
    CMP BX, [DIR_ENTRIES]
    JL .SEARCH
    JMP READ_ERR
.FOUND:
    ; DI Should hold the aDDress to the entry
    MOV AX, [DI + 26]                   ; First logical cluster field (offset 26)
    MOV [LOADER_CLUSTER], AX

    ; Lead FAT into memory
    MOV AX, [RESERVED_SECTORS]
    MOV BX, LOADER_BUFFER
    MOV CL, [SECTORS_PER_FAT_ENTRY]
    MOV DL, [DRIVE_NUM]
    CALL DISK_READ
    JC READ_ERR
    
    MOV BX, LOADER_SEGMENT
    MOV ES, BX
    MOV BX, LOADER_OFFSET
.LOOP:
    ; Read next cluster
    MOV AX, [LOADER_CLUSTER]
    ADD AX, 31
    MOV CL, 1
    MOV DL, [DRIVE_NUM]
    CALL DISK_READ
    JC READ_ERR
    ADD BX, [BYTES_PER_SECTOR]

    ; Compute the next cluster location
    MOV AX, [LOADER_CLUSTER]
    MOV CX, 3
    MUL CX
    MOV CX, 2
    DIV CX                              ; AX = Index of entry in FAT, dx = cluster % 2
    
    MOV SI, LOADER_BUFFER
    ADD SI, AX
    MOV AX, [DS:SI]
    OR DX, DX
    JZ .EVEN
.ODD:
    SHR AX, 4
    JMP .AFTER
.EVEN:
    AND AX, 0FFFh
.AFTER:
    CMP AX, 0FF8h
    JAE .FINISH
    MOV [LOADER_CLUSTER], AX
    JMP .LOOP
.FINISH:
    ; Setup video mode to 80x25 text mode
    MOV AH, 00h
    MOV AL, 03h
    INT 10h

    ; Setup the env and jump to the Loader (stage2)
    MOV DL, [DRIVE_NUM]
    MOV AX, LOADER_SEGMENT
    MOV DS, AX
    MOV ES, AX
    JMP LOADER_SEGMENT:LOADER_OFFSET
    CLI
.HALT:
    HLT
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

; *******************
; READ_ERR: Prints an error message about reading
; *******************
READ_ERR:
    LEA SI, [READ_ERR_MSG]
    CALL PRINTZ
    JMP $

; === Includes ===
%INCLUDE "sys/disk.asm"

; === Data and options ===
BOOT_MSG:                   DB '=== PiratDOS V1.0 Alpha, Bootstrap ===', 0Ah, 0Dh, 00h
READ_ERR_MSG:               DB '! Error when reading disk.', 0Ah, 0Dh, 00h

LOADER_FILE:                DB 'LOADER  SYS'
LOADER_CLUSTER:             DW 0

LOADER_SEGMENT:             EQU 2000h
LOADER_OFFSET:              EQU 0000h

; === Boot signature and paDDing ===
TIMES 510-($-$$) DB 00h
DW 0AA55h
LOADER_BUFFER: