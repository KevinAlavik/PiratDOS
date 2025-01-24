# *****************************************************
# PiratDOS V1.0 - Root Makefile
# Written by Kevin Alavik <kevin@alavik.se>, 2025
# *****************************************************

BOOT := boot
BOOT_IMG := boot.img
STAGE1 := $(BOOT)/bootstrap.bin

all: $(BOOT_IMG) 

$(STAGE1): $(BOOT)
	$(MAKE) -C $(BOOT)

$(BOOT_IMG): $(STAGE1)
	dd if=/dev/zero of=$@ bs=512 count=2880
	mkfs.fat -F 12 -n "PIRATBOOT" $@
	dd if=$(STAGE1) of=$@ conv=notrunc bs=512 count=1

clean:
	rm -f $(BOOT_IMG)
	$(MAKE) -C $(BOOT) clean

run: all
	qemu-system-x86_64 -fda $(BOOT_IMG)

.PHONY: all $(STAGE1) clean