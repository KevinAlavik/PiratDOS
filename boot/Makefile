BOOT := boot.asm
AS := nasm
ASFLAGS := -f bin
OUT := boot.bin

all: $(OUT)
$(OUT): $(BOOT)
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm $(OUT)