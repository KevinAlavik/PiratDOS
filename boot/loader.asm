; *****************************************************
; PiratDOS V1.0 - Bootloader Code (Stage 2 Bootloader)
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

BITS    16

; === PiratDOS V1.0 Bootloader entry point ===
ENTRY:
    CALL RNDR_UI
    LEA SI, [NOTE]
    CALL PRINTZ
.HALT:
    HLT
    JMP $

; === Includes ===
%INCLUDE "util/render.asm"
%INCLUDE "util/ui.asm"

; === Data ===
NOTE: DB 'No bootable options available currently.', 0Ah, 0Dh, 0
