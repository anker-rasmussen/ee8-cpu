# EE8 CPU — Instruction Set Architecture Specification

**Version:** 1.0
**Target:** Second Year Electrical Engineering — Engineering Design Module (EG2300)

---

## 1. Overview

The EE8 is a simple 8-bit CPU designed for educational purposes. It features a 16-bit instruction word, 4 registers, and a minimal instruction set- in the same vein as RISC. Students will implement this CPU in Logisim.

### Key Specifications

| Parameter | Value |
|-----------|-------|
| Data width | 8 bits |
| Instruction width | 16 bits |
| Number of registers | 4 |
| Addressing | 8-bit (256 instruction max) |
| Program memory | 0-256word ROM (expandable) |
| Signed representation | Two's complement |

---

## 2. Registers

The EE8 has four 8-bit registers, addressed with 2 bits.

| Code | Name | Description |
|------|------|-------------|
| `00` | R0 | General purpose register |
| `01` | R1 | General purpose register |
| `10` | RO | General purpose + **Output** (directly connected to 7-segment display) |
| `11` | RF | Flags register (written by LT/EQ instructions) |

RO and RF can also be denoted as R2 and R3. 

### Register Details

**R0, R1** — General purpose storage. Can be used freely for computation.

**RO/R2 (Output Register)** — Functions as a normal general-purpose register, but its contents are continuously displayed on a 7-segment display. Useful for debugging and observing program state.

**RF/R3 (Flags Register)** — Stores the result of comparison operations:
- `LT Rs1 Rs2` sets RF to `1` if Rs1 < Rs2, otherwise `0`
- `EQ Rs1 Rs2` sets RF to `1` if Rs1 == Rs2, otherwise `0`
- `JZ` and `JNZ` check if RF equals zero
- RF can be read and written like any register, but comparison instructions will overwrite it

---

## 3. Instruction Formats

All instructions are 16 bits wide. There are three instruction formats:

### 3.1 R-Type (Register Operations)

Used for ALU operations, comparisons, and register moves.

```
┌────────┬────────┬────────┬────────┬──────────────┐
│ opcode │  Rs1   │  Rs2   │   Rd   │   unused     │
│  4 bit │  2 bit │  2 bit │  2 bit │    6 bit     │
└────────┴────────┴────────┴────────┴──────────────┘
  [15:12]  [11:10]   [9:8]    [7:6]      [5:0]
```

**Fields:**
- `opcode` — Operation to perform
- `Rs1` — First source register
- `Rs2` — Second source register
- `Rd` — Destination register
- `unused` — Reserved (should be set to 0)

**Assembly syntax:** `MNEMONIC Rs1 Rs2 Rd`

**Example:** `ADD R0 R1 RO` — Adds R0 and R1, stores result in RO

**Example 2: Adding a constant**
To add a constant (e.g., 50) to R0, first load the constant into a register:
```
LDI R1 50       ; Load constant 50 into R1
ADD R0 R1 RO    ; RO = R0 + 50
```

**Example 3: Adding two constants**
To compute 50 + 100 and display the result:
```
LDI R0 50       ; R0 = 50
LDI R1 100      ; R1 = 100
ADD R0 R1 RO    ; RO = 150, displayed on 7-seg
```

### 3.2 I-Type (Immediate)

Used for loading immediate values into registers.

```
┌────────┬────────┬────────┬─────────────────────────┐
│ opcode │ unused │   Rd   │       immediate         │
│  4 bit │  2 bit │  2 bit │         8 bit           │
└────────┴────────┴────────┴─────────────────────────┘
  [15:12]  [11:10]   [9:8]          [7:0]
```

**Fields:**
- `opcode` — Operation to perform
- `unused` — Reserved (should be set to 0)
- `Rd` — Destination register
- `immediate` — 8-bit constant value (0-255 unsigned, or -128 to 127 signed)

**Assembly syntax:** `LDI Rd immediate`

**Example:** `LDI R0 42` — Loads the value 42 into R0

### 3.3 J-Type (Jump)

Used for control flow (jumps and conditional branches).

```
┌────────┬──────────────┬─────────────────────────────┐
│ opcode │    unused    │          address            │
│  4 bit │     4 bit    │           8 bit             │
└────────┴──────────────┴─────────────────────────────┘
  [15:12]     [11:8]               [7:0]
```

**Fields:**
- `opcode` — Jump type
- `unused` — Reserved (should be set to 0)
- `address` — Target instruction address (0-255)

**Assembly syntax:** `JMP address` or `JZ address` or `JNZ address`

**Example:** `JNZ 5` — If RF is not zero, jump to instruction at address 5

---

## 4. Instruction Set Reference

### 4.1 Arithmetic Instructions

#### ADD — Add
| | |
|---|---|
| **Opcode** | `0000` |
| **Format** | R-Type |
| **Syntax** | `ADD Rs1 Rs2 Rd` |
| **Operation** | `Rd = Rs1 + Rs2` |
| **Flags** | Not affected |
| **Description** | Adds the values in Rs1 and Rs2, stores the result in Rd. Overflow wraps around (modulo 256). |

**Example:**
```
LDI R0 10      ; R0 = 10
LDI R1 20      ; R1 = 20
ADD R0 R1 RO   ; RO = 30, displayed on 7-seg
```

#### SUB — Subtract
| | |
|---|---|
| **Opcode** | `0001` |
| **Format** | R-Type |
| **Syntax** | `SUB Rs1 Rs2 Rd` |
| **Operation** | `Rd = Rs1 - Rs2` |
| **Flags** | Not affected |
| **Description** | Subtracts Rs2 from Rs1, stores the result in Rd. Uses two's complement for negative results. |

**Example:**
```
LDI R0 50      ; R0 = 50
LDI R1 30      ; R1 = 30
SUB R0 R1 RO   ; RO = 20
```

---

### 4.2 Bitwise Instructions

#### AND — Bitwise AND
| | |
|---|---|
| **Opcode** | `0010` |
| **Format** | R-Type |
| **Syntax** | `AND Rs1 Rs2 Rd` |
| **Operation** | `Rd = Rs1 & Rs2` |
| **Flags** | Not affected |
| **Description** | Performs bitwise AND on Rs1 and Rs2. |

**Example:**
```
LDI R0 0b11110000   ; R0 = 240
LDI R1 0b10101010   ; R1 = 170
AND R0 R1 RO        ; RO = 0b10100000 = 160
```

#### OR — Bitwise OR
| | |
|---|---|
| **Opcode** | `0011` |
| **Format** | R-Type |
| **Syntax** | `OR Rs1 Rs2 Rd` |
| **Operation** | `Rd = Rs1 \| Rs2` |
| **Flags** | Not affected |
| **Description** | Performs bitwise OR on Rs1 and Rs2. |

#### XOR — Bitwise Exclusive OR
| | |
|---|---|
| **Opcode** | `0100` |
| **Format** | R-Type |
| **Syntax** | `XOR Rs1 Rs2 Rd` |
| **Operation** | `Rd = Rs1 ^ Rs2` |
| **Flags** | Not affected |
| **Description** | Performs bitwise XOR on Rs1 and Rs2. |

---

### 4.3 Shift Instructions

#### SHL — Shift Left
| | |
|---|---|
| **Opcode** | `0101` |
| **Format** | R-Type |
| **Syntax** | `SHL Rs1 Rs2 Rd` |
| **Operation** | `Rd = Rs1 << Rs2` |
| **Flags** | Not affected |
| **Description** | Shifts Rs1 left by Rs2 bits. Vacated bits are filled with zeros. Bits shifted out are discarded. |

**Example:**
```
LDI R0 0b00000011   ; R0 = 3
LDI R1 2            ; R1 = 2 (shift amount)
SHL R0 R1 RO        ; RO = 0b00001100 = 12
```

**Note:** Shifting left by 1 is equivalent to multiplying by 2.

#### SHR — Shift Right
| | |
|---|---|
| **Opcode** | `0110` |
| **Format** | R-Type |
| **Syntax** | `SHR Rs1 Rs2 Rd` |
| **Operation** | `Rd = Rs1 >> Rs2` |
| **Flags** | Not affected |
| **Description** | Shifts Rs1 right by Rs2 bits (logical shift). Vacated bits are filled with zeros. |

**Note:** This is a logical shift (unsigned). Shifting right by 1 is equivalent to dividing by 2 (for unsigned values).

---

### 4.4 Data Movement Instructions

#### MOV — Move (Copy Register)
| | |
|---|---|
| **Opcode** | `0111` |
| **Format** | R-Type |
| **Syntax** | `MOV Rs1 Rd` |
| **Operation** | `Rd = Rs1` |
| **Flags** | Not affected |
| **Description** | Copies the value from Rs1 to Rd. Rs2 field is ignored (set to 00). |

**Example:**
```
LDI R0 99      ; R0 = 99
MOV R0 RO      ; RO = 99, displays on 7-seg
```

**Encoding note:** Rs2 bits [9:8] are don't-care but should be set to `00`.

#### LDI — Load Immediate
| | |
|---|---|
| **Opcode** | `1010` |
| **Format** | I-Type |
| **Syntax** | `LDI Rd immediate` |
| **Operation** | `Rd = immediate` |
| **Flags** | Not affected |
| **Description** | Loads an 8-bit constant value into register Rd. |

**Example:**
```
LDI R0 255     ; R0 = 255 (max unsigned value)
LDI R1 -1      ; R1 = 255 (same in two's complement)
LDI RO 42      ; RO = 42, displays on 7-seg
```

---

### 4.5 Comparison Instructions

#### LT — Less Than
| | |
|---|---|
| **Opcode** | `1000` |
| **Format** | R-Type |
| **Syntax** | `LT Rs1 Rs2` |
| **Operation** | `RF = (Rs1 < Rs2) ? 1 : 0` |
| **Flags** | **RF is set** |
| **Description** | Compares Rs1 and Rs2 as signed two's complement values. Sets RF to 1 if Rs1 < Rs2, otherwise 0. Rd field is ignored. |

**Example:**
```
LDI R0 5       ; R0 = 5
LDI R1 10      ; R1 = 10
LT R0 R1       ; RF = 1 (because 5 < 10)
JNZ loop       ; Jump taken because RF != 0
```

**Note:** To test "greater than", swap the operand order: `LT Rs2 Rs1` tests if Rs2 < Rs1, which is equivalent to Rs1 > Rs2.

#### EQ — Equal
| | |
|---|---|
| **Opcode** | `1001` |
| **Format** | R-Type |
| **Syntax** | `EQ Rs1 Rs2` |
| **Operation** | `RF = (Rs1 == Rs2) ? 1 : 0` |
| **Flags** | **RF is set** |
| **Description** | Compares Rs1 and Rs2 for equality. Sets RF to 1 if equal, otherwise 0. Rd field is ignored. |

**Example:**
```
LDI R0 42
LDI R1 42
EQ R0 R1       ; RF = 1 (equal)
JNZ match      ; Jump taken
```

---

### 4.6 Control Flow Instructions

#### JMP — Unconditional Jump
| | |
|---|---|
| **Opcode** | `1011` |
| **Format** | J-Type |
| **Syntax** | `JMP address` |
| **Operation** | `PC = address` |
| **Flags** | Not affected |
| **Description** | Sets the program counter to the specified address. Execution continues from that instruction. |

**Example:**
```
       JMP 10      ; Jump to instruction at address 10
```

#### JZ — Jump if Zero
| | |
|---|---|
| **Opcode** | `1100` |
| **Format** | J-Type |
| **Syntax** | `JZ address` |
| **Operation** | `if (RF == 0) then PC = address` |
| **Flags** | Not affected |
| **Description** | Jumps to the specified address if RF is zero. Otherwise, continues to the next instruction. |

**Example:**
```
       EQ R0 R1    ; RF = 1 if equal, 0 if not
       JZ skip     ; Jump if NOT equal (RF == 0)
       ; ... code if equal ...
skip:  ; ... continues here ...
```

#### JNZ — Jump if Not Zero
| | |
|---|---|
| **Opcode** | `1101` |
| **Format** | J-Type |
| **Syntax** | `JNZ address` |
| **Operation** | `if (RF != 0) then PC = address` |
| **Flags** | Not affected |
| **Description** | Jumps to the specified address if RF is not zero. Otherwise, continues to the next instruction. |

**Example:**
```
       LT R0 R1    ; RF = 1 if R0 < R1
       JNZ less    ; Jump if R0 < R1
       ; ... code if R0 >= R1 ...
less:  ; ... code if R0 < R1 ...
```

---

### 4.7 Miscellaneous Instructions

#### NOP — No Operation
| | |
|---|---|
| **Opcode** | `1110` |
| **Format** | — |
| **Syntax** | `NOP` |
| **Operation** | None |
| **Flags** | Not affected |
| **Description** | Does nothing. Advances PC to next instruction. Useful for timing or placeholder. |

**Encoding:** `1110 0000 0000 0000` (all zeros after opcode)

#### HALT — Halt Execution
| | |
|---|---|
| **Opcode** | `1111` |
| **Format** | — |
| **Syntax** | `HALT` |
| **Operation** | Stop CPU |
| **Flags** | Not affected |
| **Description** | Stops the CPU. The program counter no longer advances. Used to end programs. |

**Encoding:** `1111 0000 0000 0000` (all zeros after opcode)

---

## 5. Instruction Encoding Summary

| Opcode | Binary | Mnemonic | Format | Operation |
|--------|--------|----------|--------|-----------|
| 0 | `0000` | ADD | R | Rd = Rs1 + Rs2 |
| 1 | `0001` | SUB | R | Rd = Rs1 - Rs2 |
| 2 | `0010` | AND | R | Rd = Rs1 & Rs2 |
| 3 | `0011` | OR | R | Rd = Rs1 \| Rs2 |
| 4 | `0100` | XOR | R | Rd = Rs1 ^ Rs2 |
| 5 | `0101` | SHL | R | Rd = Rs1 << Rs2 |
| 6 | `0110` | SHR | R | Rd = Rs1 >> Rs2 |
| 7 | `0111` | MOV | R | Rd = Rs1 |
| 8 | `1000` | LT | R | RF = (Rs1 < Rs2) |
| 9 | `1001` | EQ | R | RF = (Rs1 == Rs2) |
| 10 | `1010` | LDI | I | Rd = immediate |
| 11 | `1011` | JMP | J | PC = address |
| 12 | `1100` | JZ | J | if RF==0: PC = addr |
| 13 | `1101` | JNZ | J | if RF!=0: PC = addr |
| 14 | `1110` | NOP | — | No operation |
| 15 | `1111` | HALT | — | Stop execution |

---

## 6. Binary Encoding Examples

### Example 1: ADD R0 R1 RO

```
ADD  R0   R1   RO   unused
0000  00   01   10   000000

Binary: 0000 0001 1000 0000
Hex:    0x0180
```

### Example 2: LDI R0 42

```
LDI  --   R0   immediate(42)
1010  00   00   00101010

Binary: 1010 0000 0010 1010
Hex:    0xA02A
```

### Example 3: JNZ 5

```
JNZ  unused   address(5)
1101  0000    00000101

Binary: 1101 0000 0000 0101
Hex:    0xD005
```

### Example 4: LT R0 R1 (compare)

```
LT   R0   R1   --   unused
1000  00   01   00   000000

Binary: 1000 0001 0000 0000
Hex:    0x8100
```

---

## 7. Program Memory

The EE8 uses a ROM (Read-Only Memory) to store programs.

| Parameter | Value |
|-----------|-------|
| Word size | 16 bits (one instruction) |
| Address width | 8 bits |
| Capacity | 32 words (expandable to 256) |

### Program Counter (PC)
- 8-bit register
- Initializes to 0 on reset
- Increments by 1 after each instruction (unless jump taken)
- Wraps around from 255 to 0

### Fetch-Decode-Execute Cycle
1. **Fetch:** Read instruction from ROM at address PC
2. **Decode:** Extract opcode and operands
3. **Execute:** Perform operation
4. **Update PC:** PC = PC + 1 (or jump target if branch taken)

---

## 8. Timing and Clocking

The CPU operates on a single clock signal.

| Mode | Description |
|------|-------------|
| **Step mode** | Manual clock button for debugging — one instruction per press |
| **Run mode** | Continuous clock signal from oscillator |

### Clock Phases (simplified single-cycle)
On each rising clock edge:
1. Current instruction executes
2. Results written to registers
3. PC updates

All operations are **atomic** — each instruction completes in a single clock cycle.

---

## 9. Assembly Language Syntax

### Comments
```
; This is a comment
ADD R0 R1 RO    ; Inline comment
```

### Labels
```
start:  LDI R0 10
        LDI R1 1
loop:   SUB R0 R1 R0
        JNZ loop       ; Jump to 'loop' label
        HALT
```

### Numeric Formats
```
LDI R0 42          ; Decimal
LDI R0 0x2A        ; Hexadecimal
LDI R0 0b00101010  ; Binary
```

---

## 10. Example Programs

### 10.1 Count Down from 10

```
; Counts down from 10 to 0, displaying on 7-seg
        LDI RO 10      ; RO = 10, display shows 10
        LDI R1 1       ; R1 = 1 (decrement value)
        LDI RF 0       ; RF = 0 (for comparison)
loop:   EQ RO RF       ; RF = (RO == 0) ? 1 : 0
        JNZ done       ; If RO == 0, exit loop
        SUB RO R1 RO   ; RO = RO - 1
        JMP loop       ; Repeat
done:   HALT
```

### 10.2 Add Two Numbers

```
; Adds 25 + 17 and displays result
        LDI R0 25
        LDI R1 17
        ADD R0 R1 RO   ; RO = 42, displays on 7-seg
        HALT
```

### 10.3 Multiply by Shifting (x4)

```
; Multiplies R0 by 4 using left shifts
        LDI R0 7       ; R0 = 7
        LDI R1 1       ; Shift amount
        SHL R0 R1 R0   ; R0 = 14 (x2)
        SHL R0 R1 R0   ; R0 = 28 (x4)
        MOV R0 RO      ; Display result
        HALT
```

### 10.4 Find Maximum of Two Numbers

```
; Finds max of R0 and R1, stores in RO
        LDI R0 45
        LDI R1 72
        LT R0 R1       ; RF = 1 if R0 < R1
        JNZ r1_bigger  ; If R0 < R1, jump
        MOV R0 RO      ; R0 is bigger or equal
        JMP done
r1_bigger:
        MOV R1 RO      ; R1 is bigger
done:   HALT
```

---

## Appendix A: Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│                    EE8 CPU Quick Reference              │
├─────────────────────────────────────────────────────────┤
│ REGISTERS                                               │
│   R0, R1    General purpose                             │
│   RO        Output (7-seg display)                      │
│   RF        Flags (set by LT/EQ)                        │
├─────────────────────────────────────────────────────────┤
│ ARITHMETIC          │ BITWISE                           │
│   ADD Rs1 Rs2 Rd    │   AND Rs1 Rs2 Rd                  │
│   SUB Rs1 Rs2 Rd    │   OR  Rs1 Rs2 Rd                  │
│                     │   XOR Rs1 Rs2 Rd                  │
├─────────────────────┼───────────────────────────────────┤
│ SHIFT               │ COMPARE (sets RF)                 │
│   SHL Rs1 Rs2 Rd    │   LT Rs1 Rs2  (RF = Rs1 < Rs2)    │
│   SHR Rs1 Rs2 Rd    │   EQ Rs1 Rs2  (RF = Rs1 == Rs2)   │
├─────────────────────┴───────────────────────────────────┤
│ DATA MOVEMENT                                           │
│   MOV Rs Rd         Copy register                       │
│   LDI Rd imm        Load immediate (0-255)              │
├─────────────────────────────────────────────────────────┤
│ CONTROL FLOW                                            │
│   JMP addr          Unconditional jump                  │
│   JZ  addr          Jump if RF == 0                     │
│   JNZ addr          Jump if RF != 0                     │
├─────────────────────────────────────────────────────────┤
│ MISC                                                    │
│   NOP               No operation                        │
│   HALT              Stop execution                      │
└─────────────────────────────────────────────────────────┘
```

---

## Appendix B: Opcode Map

```
       0000  ADD      1000  LT
       0001  SUB      1001  EQ
       0010  AND      1010  LDI
       0011  OR       1011  JMP
       0100  XOR      1100  JZ
       0101  SHL      1101  JNZ
       0110  SHR      1110  NOP
       0111  MOV      1111  HALT
```

---

*End of EE8 CPU ISA Specification*
