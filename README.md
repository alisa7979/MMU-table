
---

# 🧠 ARM MMU Initialization and Page Table Mapping Project

This project demonstrates how to configure the **ARM MMU** on a bare-metal system using assembly. It includes:

* Page table setup (1st and optional 2nd level)
* MMU enabling with identity and non-identity mappings
* Basic memory initialization and summation
* Abort exception handling (prefetch/data abort)

Designed for educational use in systems programming or embedded architecture courses.

---

## 📂 Files

| Filename                   | Description                                                                                                                                      |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `csd_asm.S`                | Main program. Sets up MMU, initializes memory, performs summation, and handles prefetch/data aborts.                                             |
| `csd_translation_table1.s` | 1st-level translation table using 1MB section mappings. Maps VA→PA directly.                                                                     |
| `csd_translation_table2.s` | Hybrid table with 1st- and 2nd-level entries. Demonstrates how to point a 1st-level PTE to a 2nd-level page table for fine-grained 4KB mappings. |

---

## 🧭 Program Flow (from `csd_asm.S`)

### 1. **Vector Table Setup**

```asm
ldr r0, =csd_vector_table
mcr p15, 0, r0, c12, c0, 0  // Set VBAR
```

### 2. **MMU & Cache Disable**

Before changing translation:

```asm
bic r0, r0, #0x1     // disable MMU
mcr p15, 0, r0, c1, c0, 0
```

### 3. **Memory Initialization**

```asm
// Fill 12KB at physical addresses 0x400000–0x402FFF with ascending values
```

### 4. **Translation Table Base Setup**

```asm
ldr r0, =csd_MMUTable     // from either translation file
orr r0, r0, #0x5B
mcr p15, 0, r0, c2, c0, 0  // TTBR0
```

### 5. **Enable MMU**

```asm
orr r0, r0, #(1 << 0)  // Enable MMU bit
```

### 6. **Sum Over Virtual Memory**

```asm
// Sum 32-bit words at VA 0x200000 – 0x202FFF
```

Expected results:

* Using 1st-level: `0x180000` sum (1,573,376)
* Using 2nd-level: `0x7FF00` sum (523,776)

---

## 📊 Translation Table Behavior

### 🔷 `csd_translation_table1.s`

* Uses 1MB **section mappings**
* VA 0x200000 → PA 0x400000
* 3MB region for memory initialization and summation
* Uniform granularity

### 🔷 `csd_translation_table2.s`

* Uses **2nd-level page table** for 4KB mappings:

  * VA 0x200000 → PA 0x400000
  * VA 0x201000 → PA 0x402000
  * VA 0x202000 → PA 0x400000
* Shows finer-grained control and reuse of physical pages

---

## 🧪 Exception Handling

Prefetch and Data Aborts are handled via:

```asm
csd_prefetch_abort:
    mrc p15, 0, r10, c6, c0, 2  // IFAR
    mrc p15, 0, r11, c5, c0, 1  // IFSR

csd_data_abort:
    mrc p15, 0, r10, c6, c0, 0  // DFAR
    mrc p15, 0, r11, c5, c0, 0  // DFSR
```

These can be used for debugging invalid memory accesses.

---

## 🔧 Build Instructions

```bash
arm-none-eabi-as -o csd_asm.o csd_asm.S
arm-none-eabi-as -o csd_translation_table1.o csd_translation_table1.s  # OR
arm-none-eabi-as -o csd_translation_table2.o csd_translation_table2.s

arm-none-eabi-ld -Ttext=0x00000000 -o mmu_demo.elf csd_asm.o csd_translation_table1.o
# or with csd_translation_table2.o

arm-none-eabi-objcopy -O binary mmu_demo.elf mmu_demo.bin
```

Load `mmu_demo.bin` onto ZedBoard or equivalent ARM platform with MMU support.

---

## 🧠 Educational Goals

* Learn MMU setup and page table creation (section & page mappings)
* Understand virtual-to-physical translation
* Practice exception handling
* Grasp memory protection and address space management

---

