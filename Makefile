OUT := piratdos.img
STAGE1 := boot
KRNL := kernel

all: $(OUT)

$(STAGE1)/boot.bin:
	$(MAKE) -C $(STAGE1)

$(KRNL)/krnl.sys:
	$(MAKE) -C $(KRNL)

$(OUT): $(STAGE1)/boot.bin $(KRNL)/krnl.sys
	dd if=/dev/zero of=$(OUT) bs=512 count=2880
	mkfs.fat -F 12 -n "PIRATDOS" $(OUT)
	dd if=$(STAGE1)/boot.bin of=$(OUT) conv=notrunc bs=512 count=1
	mcopy -i $(OUT) $(KRNL)/krnl.sys "::krnl.sys"

clean:
	$(MAKE) -C $(STAGE1) clean
	$(MAKE) -C $(KRNL) clean
	rm -f $(OUT)

run: $(OUT)
	qemu-system-i386 -fda $(OUT)
