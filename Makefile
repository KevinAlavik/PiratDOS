# *****************************************************
# PiratDOS V1.0 - Root Makefile
# Written by Kevin Alavik <kevin@alavik.se>, 2025
# *****************************************************

BOOT := boot
BOOT_IMG := boot.img
STAGE1 := $(BOOT)/bootstrap.bin
STAGE2 := $(BOOT)/loader.bin

all: $(BOOT_IMG) 
$(STAGE1) $(STAGE2): $(BOOT)
	$(MAKE) -C $(BOOT)

$(BOOT_IMG): $(STAGE1) $(STAGE2)
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n "PIRATBOOT" $@
	dd if=$(STAGE1) of=$@ conv=notrunc bs=512 count=1
	mcopy -i $@ $(STAGE2) ::loader.sys
	mcopy -i $@ test.txt ::test.txt
clean:
	rm -f $(BOOT_IMG)
	$(MAKE) -C $(BOOT) clean

run: all
	qemu-system-x86_64 -fda $(BOOT_IMG)

.PHONY: all $(STAGE1) clean