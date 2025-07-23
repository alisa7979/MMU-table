.align 5
csd_vector_table:
    b .
    b .
    b .
    b csd_prefetch_abort
    b csd_data_abort
    b .
    b .
    b .

.global main
main:
    // Set up Vector Base Address Register
    ldr r0, =csd_vector_table
    mcr p15, 0, r0, c12, c0, 0
    dsb
    isb

    // Disable MMU and invalidate caches and TLBs
    mrc p15, 0, r0, c1, c0, 0
    bic r0, r0, #0x1
    mcr p15, 0, r0, c1, c0, 0

    mov r0, #0
    mcr p15, 0, r0, c8, c7, 0
    mcr p15, 0, r0, c7, c5, 0
    mcr p15, 0, r0, c7, c5, 6


    // initialize main memory like Figure 1
    // physical addresses: 0x400000, 0x401000, 0x402000

    ldr r0, =0x400000     // start address in physical memory
    ldr r1, =-1024        // initial value
    mov r2, #0            // counter: number of words written
    mov r3, #3072         // total number of words to write

init_loop:
    cmp r1, #0
    beq skip_write

    str r1, [r0], #4      // store and post-increment address
    add r2, r2, #1        // count written values

skip_write:
    add r1, r1, #1        // next value
    cmp r2, r3
    blt init_loop


    // set up page table (TTBR0) with csd_MMUTable
    // which maps VA 0x200000–0x202FFF to PA 0x400000–0x402FFF

    ldr r0, =csd_MMUTable
    orr r0, r0, #0x5B
    mcr p15, 0, r0, c2, c0, 0   // TTBR0

    // Enable HW page walk (clear PD0)
    mrc p15, 0, r1, c2, c0, 2
    bic r1, r1, #(1 << 4)
    mcr p15, 0, r1, c2, c0, 2

    // Enable MMU
    mrc p15, 0, r0, c1, c0, 0
    bic r0, r0, #(1 << 12)  // I$ disable
    bic r0, r0, #(1 << 2)   // D$ disable
    orr r0, r0, #(1 << 0)   // M = 1
    mcr p15, 0, r0, c1, c0, 0
    dsb
    isb


    // sum all 32-bit words in VA 0x200000–0x202FFF (12KB)

    ldr r0, =0x200000       // start VA
    ldr r1, =0x203000       // end VA (exclusive)
    mov r2, #0              // accumulator
sum_loop:
    ldr r3, [r0]
    add r2, r2, r3
    add r0, r0, #4
    cmp r0, r1
    blt sum_loop

    // final sum is in r2 (should be 1,573,376 and 523,776)
    b forever

forever:
    nop
    b forever

// Exception Handlers
csd_prefetch_abort:
    mrc p15, 0, r10, c6, c0, 2  // IFAR
    mrc p15, 0, r11, c5, c0, 1  // IFSR
    b .

csd_data_abort:
    mrc p15, 0, r10, c6, c0, 0  // DFAR
    mrc p15, 0, r11, c5, c0, 0  // DFSR
    b .
