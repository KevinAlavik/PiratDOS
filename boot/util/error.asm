; *****************************************************
; PiratDOS V1.0 - Error Handlers
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

%IFNDEF ERROR_ASM
%DEFINE ERROR_ASM

; *******************
; DISK_READ_ERROR: Handles disk read fails.
; *******************
DISK_READ_ERROR:
    ; Print out message
    LEA SI, [NOTE]
    CALL PRINTZ

    ; Halt sytem
    JMP HALT

; *******************
; HALT: Halt the system
; *******************
HALT:
    JMP HALT

; === Includes ===
%include "util/render.asm"

; === ERROR Messages ===
DISK_READ_ERROR_MSG: DB 'ERROR: Failed to read disk', 0

%ENDIF ; ERROR_ASM
