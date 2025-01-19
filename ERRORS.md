# PiratDOS Error Table
| Error Code | Description                                         | Fatal |
|------------|-----------------------------------------------------|-------|
| 0xC001     | Bootloader: Failed to read from disk                | NO    |
| 0xC002     | Bootloader: Failed to find KRNL.SYS                 | YES   |
| 0xC003     | Bootloader: Kernel returned where it shouldnt have  | NO*   |
| 0xA001     | Kernel: Not Implemented                             | NO*   |
\*: Could be considered fatal depending on context.