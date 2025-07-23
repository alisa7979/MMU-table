// 2nd level page table 1KB (=256 x 4B)
.globl csd_MMUTable_lv2
.section .csd_mmu_tbl_lv2, "a"
.align 10                      	// align 1KB
csd_MMUTable_lv2:
    .word 0x400002       		// VA 0x200000 → PA 0x400000
    .word 0x402002       		// VA 0x201000 → PA 0x402000
    .word 0x400002       		// VA 0x202000 → PA 0x400000

.globl  csd_MMUTable
.section .csd_mmu_tbl,"a"
csd_MMUTable:
	.set SECT, 0
	.word	SECT + 0x15de6

	.set SECT, 0x100000
	.word	SECT + 0x15de6

	.set SECT, 0x200000
	.word	csd_MMUTable_lv2 + 0x1e1  // go to level 2 page table

	.set SECT, 0x300000
	.word	SECT + 0x15de6

	.set SECT, 0x400000
	.word	SECT + 0x15de6

	.set SECT, 0x500000
	.word	SECT + 0x15de6

	.rept (0x200 - 6)
	.word	SECT + 0x15de6
	.endr

