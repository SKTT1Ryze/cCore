# RISC-V Assembly Language: https://github.com/riscv/riscv-asm-manual/blob/master/riscv-asm.md

    .section .text.entry
    .globl _start

_start:
    la sp, boot_stack_top
    call c_main

    .section .bss.stack
    .global boot_stack
boot_stack:
    # 16K boot stack
    .space 4096 * 16
    .global boot_stack_top
boot_stack_top:
    # end of stack