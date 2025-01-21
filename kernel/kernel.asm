;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pirat DOS v1.0 Alpha      ;
;  - Kernel entry point     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ORG 0x0000
BITS 16

%include "utils.inc"

; --------------------- ;
;  Kernel Entry         ;
; --------------------- ;
init:
    call render_screen
    println "Insert program floppy and press ENTER..."
.loop:
    ; Wait for keypress
    mov ah, 0
    int 16h
    cmp al, 13                 ; Check if ASCII code of Enter key (13) was pressed
    je load_prgm_disk          ; Continue with loading the program disk
    jne .loop

; --------------------- ;
;  Program Disk Loading ;
; --------------------- ;
load_prgm_disk:
    println "Loading program disk..."
    mov dl, PRGRM_DISK         ; DL: 0x01 = 2nd floppy drive
    mov ah, 0x00
    int 0x13

    cmp ah, 0
    jne .load_error
    
    call .load_fat12_header
    println "Loaded FAT12 header!"

    printnum [test_thing]

    jmp $
.load_fat12_header:
    mov ah, 0x02
    mov al, 0x01                ; Just read a single sector
    mov ch, 0                   ; Cylinder 0
    mov cl, 0                   ; Sector 0
    mov dh, 0                   ; Head 0
    mov dl, PRGRM_DISK          ; The program diskette
    mov ax, 0x0000
    mov es, ax
    mov bx, bdb_oem
    int 0x13
    jc .disk_read_error
    ret
.load_error:
    error "0xA002", "Failed to load disk 2."
    jmp error_handle
.disk_read_error:
    error "0xA003", "Disk read error when reading program disk."
    jmp error_handle
.disk_error:
    error "0xA004", "Generic disk error when loading program disk."
    jmp error_handle

; --------------------- ;
;  Utility Functions    ;
; --------------------- ;

; Prints a single character to the screen, page number 0.
; Arguments:
;   - al: Character to print
;   - bl: Attribute for the character
putchar:
    push ax
    push bx
    push cx

    mov ah, 0x0E
    mov bh, 0x00
    int 0x10

    pop cx
    pop bx
    pop ax
    ret

; Error handler
error_handle:
    println "An error has occurred press any button to reboot."
    mov ah, 0
    int 16h                     ; Wait for keypress
    jmp 0xFFFF:0                ; Jump to beginning of BIOS, should reboot

; Renders the screen.
render_screen:
    clear_screen
    set_cursor 0
    goto 0, 23
    %rep 80
        print "-"
    %endrep
    print "PiratDOS v1.0 Alpha - Copyright (c) Kevin Alavik 2025"
    goto 0, 0
    ret

; --------------- ;
;  Disk Routines  ;
; --------------- ;
; Converts an LBA address to the CHS format
; Arguments:
;   - ax: LBA Address
; Returns:
;   - cx (bits 0-5): sector number
;   - cx (bits 6-15): cylinder
;   - dh: head
lba_to_chs:
    push ax
    push dx

    xor dx, dx                          ; dx = 0
    div word [bdb_sectors_per_track]    ; ax = LBA / sectors_per_track
                                        ; dx = LBA % sectors_per_track

    inc dx                              ; dx = (LBA % sectors_per_track) + 1 = sector
    mov cx, dx                          ; cx = sector

    xor dx, dx                          ; dx = 0
    div word [bdb_heads]                ; ax = (LBA / sectors_per_track) / heads = cylinder
                                        ; dx = (LBA / sectors_per_track) % heads = head
    mov dh, dl                          ; dh = head
    mov ch, al                          ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                           ; Put upper 2 bits of cylinder in CL

    pop ax
    mov dl, al
    pop ax
    ret

; Reads sectors from a disk
; Arguments:
;   - ax: LBA Address
;   - cl: Number of sectors to read (max: 128)
;   - dl: Drive number
;   - es:bx: Read buffer
disk_read:
    push ax
    push bx
    push cx
    push dx
    push di

    push cx                             ; Temporarily save CL (number of sectors to read)
    call lba_to_chs                     ; Compute CHS
    pop ax                              ; AL = number of sectors to read
    
    mov ah, 02h
    mov di, DISK_READ_RETRY_COUNT
.retry:
    pusha
    stc                                 ; Set carry flag, some BIOS dont set it
    int 13h                             ; Carry flag cleared = success
    jnc .done                           ; If the carry flag is cleared we successfully read.

    ; Read failed
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry
.fail:
    jmp disk_error
.done:
    popa
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; Reset disk controller
; Arguments:
;   - dl: Drive number
disk_reset:
    pusha
    mov ah, 0
    stc
    int 0x13
    jc disk_error
    popa
    ret

disk_error:
    error "0xA004", "Generic disk error."
    jmp error_handle


; --------------- ;
;  Generic Data   ;
; --------------- ;
DISK_READ_RETRY_COUNT       equ 3
PRGRM_DISK                  equ 0x01

test_thing: db 69

; --------------- ;
;  FAT12 Header   ;
; --------------- ;
bdb_oem:                    db 0, 0, 0, 0, 0, 0, 0, 0
bdb_bytes_per_sector:       dw 0
bdb_sectors_per_cluster:    db 0
bdb_reserved_sectors:       dw 0
bdb_fat_count:              db 0
bdb_dir_entries_count:      dw 0
bdb_total_sectors:          dw 0
bdb_media_descriptor_type:  db 0
bdb_sectors_per_fat:        dw 0
bdb_sectors_per_track:      dw 0
bdb_heads:                  dw 0
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0
ebr_drive_number:           db 0
ebr_reserved:               db 0
ebr_signature:              db 0
ebr_volume_id:              db 0x00, 0x00, 0x00, 0x00
ebr_volume_label:           db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
ebr_system_id:              db 0, 0, 0, 0, 0, 0, 0, 0
