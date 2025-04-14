# *****************************************************
# PiratDOS V1.0 - Bootloader Makefile
# Written by Kevin Alavik <kevin@alavik.se>, 2025
# *****************************************************

ASM_FILES := $(wildcard *.asm)
BIN_FILES := $(ASM_FILES:.asm=.bin)

all: $(BIN_FILES)

%.bin: %.asm
	nasm -fbin -o $@ $<

clean:
	rm -f $(BIN_FILES)

.PHONY: all clean