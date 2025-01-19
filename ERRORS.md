# PiratDOS Error Table
| Error Code | Description                                         | Fatal |
|------------|-----------------------------------------------------|-------|
| 0xC001     | Bootloader: Failed to read from disk                | NO    |
| 0xC002     | Bootloader: Failed to find KRNL.SYS                 | YES   |
| 0xC003     | Bootlaoder: Kernel returned where it shouldnt have  | NO*   |
\*: Could be considered fatal since the kernel exited without reason