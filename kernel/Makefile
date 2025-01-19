BOOT := kernel.asm
AS := nasm
ASFLAGS := -f bin
OUT := krnl.sys

all: $(OUT)
$(OUT): $(BOOT)
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm $(OUT)