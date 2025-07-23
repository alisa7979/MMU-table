.globl  csd_MMUTable
.section .csd_mmu_tbl,"a"

csd_MMUTable:
	 /*A 32-bit is required for each PTE (Page Table Entry).
	  * Each PTE covers a 1MB section.
	  * There are 4096 PTEs, so 16KB is required for the page table.
	  *
	  *  First 6 PTEs with the following translations
	  *     1st 1MB: 0x0000_0000 (VA) -> 0x0000_0000 (PA)
	  *     2nd 1MB: 0x0010_0000 (VA) -> 0x0010_0000 (PA)
	  *     3rd 1MB: 0x0020_0000 (VA) -> 0x0040_0000 (PA)
	  *     4th 1MB: 0x0030_0000 (VA) -> 0x0030_0000 (PA)
	  *     5th 1MB: 0x0040_0000 (VA) -> 0x0020_0000 (PA)
	  *     6th 1MB: 0x0050_0000 (VA) -> 0x0050_0000 (PA)
	  */
	.set SECT, 0
	.word	SECT + 0x15de6

	.set SECT, 0x100000
	.word	SECT + 0x15de6

	.set SECT, 0x400000
	.word	SECT + 0x15de6

	.set SECT, 0x300000
	.word	SECT + 0x15de6

	.set SECT, 0x200000
	.word	SECT + 0x15de6

	.set SECT, 0x500000
	.word	SECT + 0x15de6

	.rept (0x200 - 6)
	.word	SECT + 0x15de6
	.endr


