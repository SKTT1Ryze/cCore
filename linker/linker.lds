/* https://sourceware.org/binutils/docs/ld/Scripts.html */

/* target arch */
OUTPUT_ARCH(riscv)

/* entry */
ENTRY(_start)

/* base address */
BASE_ADDRESS = 0x80200000;

SECTIONS
{
    . = BASE_ADDRESS;

    kernel_start = .;

    text_start = .;

    .text : {
        *(.text.entry)
        *(.text .text.*)
    }

    rodata_start = .;

    .rodata : {
        *(.rodata .rodata.*)
    }

    data_start = .;

    /* .data 字段 */
    .data : {
        *(.data .data.*)
    }

    bss_start = .;

    /* .bss 字段 */
    .bss : {
        *(.sbss .bss .bss.*)
    }

    /* end of kernel */
    kernel_end = .;
}