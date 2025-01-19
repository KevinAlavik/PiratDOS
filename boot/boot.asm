;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pirat DOS v1.0 Alpha      ;
;  - Bootloader entry point ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Special thanks to nanobyte and his series: https://github.com/nanobyte-dev/nanobyte_os

ORG     0x7C00
BITS    16

jmp short entry
nop

; --------------- ;
;  FAT12 Header   ;
; --------------- ;

bdb_oem:                    db 'MSWIN4.1'
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0xE0
bdb_total_sectors:          dw 2880                 ; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:  db 0xF0                 ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; Extended boot record
ebr_drive_number:           db 0x00
                            db 0x00
ebr_signature:              db 0x29
ebr_volume_id:              db 0x12, 0x34, 0x56, 0x78
ebr_volume_label:           db 'PIRATDOS   '
ebr_system_id:              db 'FAT12   '

; --------------- ;
;  Entry point    ;
; --------------- ;
entry:
    ; Setup the data segments
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; Setup stack
    mov ss, ax
    mov sp, 0x7C00

    ; Make sure we are at 0000:7C00
    push es
    push word .start
    retf
.start:
    ; Store the drive number
    mov [ebr_drive_number], dl

    ; Setup the video mode, 80x25 text mode (0x03)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Clear screen
    mov ah, 0x06         ; Function 6: Scroll up
    mov al, 0x00         ; Scroll entire screen
    mov bh, 0x07         ; Attribute for blank spaces (white on black)
    mov cx, 0x0000       ; Top-left corner (row 0, column 0)
    mov dx, 0x184F       ; Bottom-right corner (row 24, column 79)
    int 0x10

    ; Read driver information (sectors per track and head)
    push es
    mov ah, 0x08
    mov dl, [ebr_drive_number]
    int 0x13
    jc floppy_error
    pop es

    and cl, 0x3F
    xor ch, ch
    mov [bdb_sectors_per_track], cx
    
    inc dh
    mov [bdb_heads], dh

    ; Compute the LBA of the root directory
    ;   root = reserved + fats * sectors_per_fat
    mov ax, [bdb_sectors_per_fat]
    mov bl, [bdb_fat_count]
    xor bh, bh
    mul bx                              ; ax = (fats * sectors_per_fat)
    add ax, [bdb_reserved_sectors]      ; ax = LBA of root directory
    push ax

    ; Compute the size of the root directory
    ;   size = (32 * number_of_entries) / bytes_per_sector
    mov ax, [bdb_dir_entries_count]
    shl ax, 5                           ; ax *= 32
    xor dx, dx                          ; dx = 0
    div word [bdb_bytes_per_sector]     ; Sectors to read

    test dx, dx                         ; if dx != 0, add 1
    jz .root_dir_after
    inc ax                              ; Division remainder != 0, add 1
.root_dir_after:
    ; Read root directory
    mov cl, al                          ; cl = Sectors to read = size of root
    pop ax                              ; ax = LBA of root
    mov dl, [ebr_drive_number]          ; dl = drive number
    mov bx, buffer                      ; es:bx = buffer
    call disk_read

    ; Search for krnl.sys
    xor bx, bx
    mov di, buffer
.search_kernel:
    mov si, krnl_path
    mov cx, 11                          ; Compare up-to 11 characters
    push di
    repe cmpsb
    pop di
    je .found_kernel

    add di, 32
    inc bx
    cmp bx, [bdb_dir_entries_count]
    jl .search_kernel

    ; Kernel not found
    jmp kernel_not_found_error
.found_kernel:
    ; di should hold the address to the entry
    mov ax, [di + 26]                   ; First logical cluster field (offset 26)
    mov [kernel_cluster], ax

    ; Load FAT from disk into memory
    mov ax, [bdb_reserved_sectors]
    mov bx, buffer
    mov cl, [bdb_sectors_per_fat]
    mov dl, [ebr_drive_number]
    call disk_read

    ; Read kernel and process FAT chain
    mov bx, KERNEL_LOAD_SEGMENT
    mov es, bx
    mov bx, KERNEL_LOAD_SEGMENT
.load_kernel_loop:
    ; Read next cluster
    mov ax, [kernel_cluster]

    ; Hardcoded offset
    add ax, 31

    mov cl, 1
    mov dl, [ebr_drive_number]
    call disk_read

    add bx, [bdb_bytes_per_sector]

    ; Compute location of next cluster
    mov ax, [kernel_cluster]
    mov cx, 3
    mul cx
    mov cx, 2
    div cx                              ; ax = index of entry in FAT, dx = cluster mod 2

    mov si, buffer
    add si, ax
    mov ax, [ds:si]                     ; Read entry from FAT table at index ax

    or dx, dx
    jz .even
.odd:
    shr ax, 4
    jmp .next_cluster_after
.even:
    and ax, 0x0FFF
.next_cluster_after:
    cmp ax, 0x0FF8                      ; End of chain
    jae .read_finish
    mov [kernel_cluster], ax
    jmp .load_kernel_loop
.read_finish:
    mov dl, [ebr_drive_number]          ; Boot device in dl
    mov ax, KERNEL_LOAD_SEGMENT         ; Set segment registers
    mov ds, ax
    mov es, ax
    jmp KERNEL_LOAD_SEGMENT:KERNEL_LOAD_OFFSET
    jmp wait_key                        ; If kernel ever returns, just reboot on user input.
    cli                                 ; Disable interrupts, this way CPU can't get out of "halt" state
    hlt
.halt:
    hlt
    jmp .halt


; --------------------- ;
;  Error Functions      ;
; --------------------- ;
floppy_error:
    mov si, error_read_fail
    call puts
    jmp wait_key
kernel_not_found_error:
    mov si, error_krnl_not_found
    call puts
    jmp wait_key
wait_key:
    mov ah, 0
    int 16h                     ; Wait for keypress
    jmp 0xFFFF:0                ; Jump to beginning of BIOS, should reboot


; --------------------- ;
;  Utility Functions    ;
; --------------------- ;

; Prints a string to the screen, page number 0.
; Arguments:
;   - ds:si, String pointer
puts:
    push si
    push ax
    push bx
.loop:
    lodsb
    or al, al
    jz .done
    call putchar
    jmp .loop
.done:
    pop bx
    pop ax
    pop si    
    ret

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
    mov cx, 1
    int 0x10

    pop cx
    pop bx
    pop ax
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
    jmp floppy_error
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
    jc floppy_error
    popa
    ret

; --------------- ;
;  Data           ;
; --------------- ;
krnl_path:              db 'KRNL  SYS'
kernel_cluster:         dw 0

error_read_fail:        db '0xC001', 0
error_krnl_not_found:   db '0xC002', 0

KERNEL_LOAD_SEGMENT     equ 0x2000
KERNEL_LOAD_OFFSET      equ 0

DISK_READ_RETRY_COUNT   equ 3

; Signature and padding
times 510-($-$$) db 0
dw 0xAA55
buffer: