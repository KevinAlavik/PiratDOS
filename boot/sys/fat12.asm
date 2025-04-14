; *****************************************************
; PiratDOS V1.0 - FAT12 Utilities
; Written by Kevin Alavik <kevin@alavik.se>, 2025
; *****************************************************

%IFNDEF FAT12_ASM
%DEFINE FAT12_ASM

STRUC FAT12Header
    .jmp_code               RESB 3
    .oem_name               RESB 8
    .bytes_per_sector       RESW 1
    .sectors_per_cluster    RESB 1
    .reserved_sectors       RESW 1
    .num_fats               RESB 1
    .root_entries           RESW 1
    .total_sectors_16       RESW 1
    .media_descriptor       RESB 1
    .sectors_per_fat        RESW 1
    .sectors_per_track      RESW 1
    .num_heads              RESW 1
    .hidden_sectors         RESD 1
    .total_sectors_32       RESD 1
    .drive_number           RESB 1
    .reserved1              RESB 1
    .boot_signature         RESB 1
    .volume_id              RESD 1
    .volume_label           RESB 11
    .filesystem_type        RESB 8
ENDSTRUC

%ENDIF ; FAT12_ASM