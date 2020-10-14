# Makefile for build cCore

ARCH_LEN			:= 64
platform			:= k210
src_path			:= ./src
target_path			:= ./target
linker_path			:= ./linker
main_src			:= $(src_path)/main.c
sbi_src				:= $(src_path)/sbi/sbi.c
entry_src			:= $(src_path)/asm/entry_$(platform).s

main_obj			:= ./main.o
sbi_obj				:= ./sbi.o
entry_obj			:= ./entry_$(platform).o

kernel				:= $(target_path)/kernel
k210				:= $(target_path)/k210.bin
image				:= $(target_path)/kernel.bin

linker				:= $(linker_path)/linker_$(platform).lds

CROSS_COMPILE		:= riscv64-unknown-elf-
CC					:= $(CROSS_COMPILE)gcc
objcopy				:= $(CROSS_COMPILE)objcopy

LD					:= $(CC)
LDFLAGS				:= -Wl,--build-id=none -nostartfiles -nostdlib -static -fno-stack-protector
LIBS				:= -lgcc
LINK				:= $(LD) $(LDFLAGS)

QEMU				:= qemu-system-riscv$(ARCH_LEN)

OPENSBI				:= ./SBI/opensbi.bin
RUSTSBI				:= ./SBI/rustsbi.bin
k210-serialport		:= /dev/ttyUSB0

object:
	@$(CC) -c $(main_src)
	@$(CC) -c $(sbi_src)
	@$(CC) -c $(entry_src)

build: object
	@rm -rf $(target_path)/*
	@$(LINK) -o $(kernel) $(main_obj) $(sbi_obj) $(entry_obj) $(LIBS) -Wl,--defsym=MEM_START=0x80000000,-T,$(linker)
	@rm *.o

k210: build
	@riscv64-unknown-elf-objcopy $(kernel) --strip-all -O binary $(image)
	@cp $(RUSTSBI) $(k210)
	dd if=$(image) of=$(k210) bs=128k seek=1

qemu: build
	@$(QEMU) \
	-machine virt \
    -nographic \
    -bios default \
    -device loader,file=$(kernel),addr=0x80200000

run: build qemu

run-k210: k210
	@sudo chmod 777 $(k210-serialport)
	python3 ./flash/kflash.py -p $(k210-serialport) -b 1500000 -t $(k210)

clean:
	@rm -rf $(target_path)/*