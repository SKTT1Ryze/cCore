// SBI Call Implementation

const int SBI_CONSOLE_PUTCHAR = 1;
const int SBI_SHUTDOWN = 8;

static int sbi_call(int which, int arg0, int arg1, int arg2) {
    int ret;
    asm volatile (
        "lw x10, %1 \n\t"
        "lw x11, %2 \n\t"
        "lw x12, %3 \n\t"
        "lw x17, %4 \n\t"
        "ecall \n\t"
        "sw x10, %0 \n\t"
        :"=m"(ret)
        :"m"(arg0), "m"(arg1), "m"(arg2), "m"(which)
        :"memory"
    );
    return ret;
}

// put a char in console
void sbi_console_putchar(int ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}