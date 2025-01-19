OUT := piratdos.img
STAGE1 := boot
KRNL := kernel
PRGRM_DISK := bundle.img

all: $(OUT)

$(STAGE1)/boot.bin:
	$(MAKE) -C $(STAGE1)

$(KRNL)/krnl.sys:
	$(MAKE) -C $(KRNL)

# Create a standard 3.5" floppy disk for the OS
$(OUT): $(STAGE1)/boot.bin $(KRNL)/krnl.sys
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n "PIRATDOS" $@
	dd if=$(STAGE1)/boot.bin of=$@ conv=notrunc bs=512 count=1
	mcopy -i $@ $(KRNL)/krnl.sys ::krnl.sys

# Create a standard 3.5" floppy disk for bundled programs
$(PRGRM_DISK): test.txt
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n "PIRATAPPS" $@
	mcopy -i $@ test.txt ::test.txt

clean:
	$(MAKE) -C $(STAGE1) clean
	$(MAKE) -C $(KRNL) clean
	rm -f $(OUT)

run: $(OUT) $(PRGRM_DISK)
	qemu-system-i386 -fda $(OUT) -fdb $(PRGRM_DISK)

debug: $(OUT) $(PRGRM_DISK)
	qemu-system-i386 -fda $(OUT) \
		-S -gdb tcp::1234 \
		-d cpu,exec,int \
		-no-reboot -no-shutdown \
		-debugcon stdio

.PHONY: all clean run debug
