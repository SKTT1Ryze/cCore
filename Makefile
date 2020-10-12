# Makefile for build cCore

ARCH_LEN			:= 64
src_path			:= ./src
target_path			:= ./target
linker_path			:= ./linker
main_src			:= $(src_path)/main.c
sbi_src				:= $(src_path)/sbi/sbi.c
entry_src			:= $(src_path)/asm/entry.s

main_obj			:= ./main.o
sbi_obj				:= ./sbi.o
entry_obj			:= ./entry.o

kernel				:= $(target_path)/kernel.bin

linker				:= $(linker_path)/linker.lds

CC					:= riscv64-unknown-elf-gcc

LD					:= $(CC)
LDFLAGS				:= -Wl,--build-id=none -nostartfiles -nostdlib -static -fno-stack-protector
LIBS				:= -lgcc
LINK				:= $(LD) $(LDFLAGS)

QEMU				:= qemu-system-riscv$(ARCH_LEN)

SBI					:= default

object:
	@$(CC) -c $(main_src)
	@$(CC) -c $(sbi_src)
	@$(CC) -c $(entry_src)

build: object
	@rm -rf $(target_path)/*
	@$(LINK) -o $(kernel) $(main_obj) $(sbi_obj) $(entry_obj) $(LIBS) -Wl,--defsym=MEM_START=0x80000000,-T,$(linker)
	@rm *.o

qemu: build
	@$(QEMU) \
	-machine virt \
    -nographic \
    -bios $(SBI) \
    -device loader,file=$(kernel),addr=0x80200000

run: build qemu

clean:
	@rm -rf $(target_path)/*