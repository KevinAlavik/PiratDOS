; *****************************************************
; PiratDOS V1.0 - Disk Utilities
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

; *******************
; LBA_TO_CHS: Converts an LBA aDDress to the CHS format
; Arguments:
;   - AX: LBA aDDress to convert
; Returns:
;   - CX (Bits 0-5): Sector
;   - CX (Bits 6-15): Cylinder
;   - DH: Head
; *******************
LBA_TO_CHS:
    PUSH AX
    PUSH DX
    
    XOR DX, DX                          ; Zero out DX
    DIV WORD [SECTORS_PER_TRACK]        ; AX = LBA / SECTORS_PER_TRACK
                                        ; DX = LBA % SECTORS_PER_TRACK

    INC DX                              ; DX = (LBA % SECTORS_PER_TRACK) + 1 = SECTOR
    MOV CX, DX                          ; CX = Sector

    XOR DX, DX                          ; Zero out DX
    DIV WORD [HEADS]                    ; AX = (LBA / SECTORS_PER_TRACK) / HEADS = CYLINDER
                                        ; DX = (LBA / SECTORS_PER_TRACK) % HEADS = HEAD
    MOV DH, DL                          ; DH = HEAD
    MOV CH, AL                          ; CH = CYLINDER (LOW 8 BITS)
    SHL AH, 6
    OR CL, AH                           ; CL = CYLINDER (UPP 2 BITS)

    POP AX
    MOV DL, AL
    POP AX
    RET

; *******************
; DISK_READ: Reads sectors from a disk
; Arguments:
;   - AX: LBA ADDress
;   - CL: Number of sectors to read (MAX 128)
;   - DL: Drive number
;   - ES:BX - Buffer to store the data
; *******************
DISK_READ:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI

    PUSH CX                             ; Store numbers of sectors to read on the stack
    CALL LBA_TO_CHS                     ; Calculate the CHS
    POP AX                              ; CL = Sectors to read

    MOV AH, 02h
    MOV DI, DISK_READ_RETRY_COUNT
.RETRY:
    PUSHA
    STC
    INT 13h
    JNC .DONE
    POPA
    CALL DISK_RESET
    DEC DI 
    TEST DI, DI
    JNZ .RETRY
.FAIL:
    STC
.DONE:
    POPA
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    RET


; *******************
; DISK_RESET: Resets disk controller
; Arguments: 
;   - DL: Drive number
; *******************
DISK_RESET:
    PUSHA
    MOV AH, 0
    STC
    INT 13h
    POPA
    RET

DISK_READ_RETRY_COUNT:      EQU 10