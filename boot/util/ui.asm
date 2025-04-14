; *****************************************************
; PiratDOS V1.0 - UI Rendering For Stage 2
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

; === Generic Render Functions ===
; *******************
; RNDR_UI: Renders the User Interface
; Arguments: None
; *******************
RNDR_UI:
    PUSHA
    GOTO 0, 23
    LEA SI, [SEPERATOR]
    CALL PRINTZ
    GOTO 0, 24
    LEA SI, [BOTTOM_BAR]
    CALL PRINTZ
    GOTO 0, 0
    POPA
    RET

; === UI Elements ===
BOTTOM_BAR:
    DB 'PiratDOS v1.0 Alpha - Copyright (c) Kevin Alavik 2025'
    TIMES 15 DB '.'
    DB '(Bootloader)', 0
SEPERATOR:
    %rep 40
    DB '-'
    DB '*'
    %endrep
    DB 0
