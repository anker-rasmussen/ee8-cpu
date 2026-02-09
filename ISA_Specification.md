# EE8 CPU — Instruction Set Architecture Specification

**Version:** 3.0  
**Target:** Second Year Electrical Engineering — Engineering Design Module (EG2300)

---

## 1. Overview

The EE8 is a simple 8-bit CPU designed for educational purposes. It features a 16-bit instruction word, 4 general-purpose registers, and a minimal RISC-style instruction set. Students will implement this CPU in Logisim to control a batch diverter manufacturing station.

### Key Specifications

| Parameter | Value |
|-----------|-------|
| Data width | 8 bits |
| Instruction width | 16 bits |
| Number of registers | 4 |
| Addressing | 4-bit (16 instructions max) |
| Program memory | 16-word ROM |
| Signed representation | Two's complement |

---

## 2. Registers

The EE8 has four 8-bit general-purpose registers, addressed with 2 bits.

| Code | Name | Description |
|------|------|-------------|
| `00` | R0 | General purpose register |
| `01` | R1 | General purpose register |
| `10` | R2 | General purpose register |
| `11` | R3 | General purpose register (also used for comparison results) |

All registers are fully general-purpose and can be used for computation, storage, or I/O operations.

### R3 and Comparison Operations

R3 serves double duty as the destination for comparison instructions:
- `LT Rs1 Rs2` sets R3 to `1` if Rs1 < Rs2, otherwise `0`
- `EQ Rs1 Rs2` sets R3 to `1` if Rs1 == Rs2, otherwise `0`
- `JZ` and `JNZ` check if R3 equals zero
- R3 can be read and written like any register, but comparison instructions will overwrite it

### Design Note: Why R3 is a Full Register

Unlike traditional CPUs (x86, ARM) which use packed bit flags (N, Z, C, V), EE8 uses a full 8-bit register for comparison results. This design choice follows modern RISC philosophy (RISC-V):

**Advantages:**
- **Simpler hardware** — No bit-field extraction logic needed
- **Orthogonal design** — R3 can be used like any other register (read, write, arithmetic)
- **Easier to implement** — Students build standard 8-bit register, not special flag register
- **Modern approach** — RISC-V (2010s) uses explicit comparison results, not implicit flags

**Trade-offs:**
- Cannot branch on overflow or unsigned comparisons without additional instructions
- Acceptable for EE8's educational scope and target applications

---

## 3. I/O Interface

The EE8 must interface with external signals for the batch diverter station. Teams must choose **one** of the following I/O strategies and document their choice in the report.

### Platform Signals

**Inputs (directly from pins, directly to external ports):**
| Bit | Signal | Description |
|-----|--------|-------------|
| 0 | ITEM_PULSE | One pulse per item passing the counting point |
| 1 | STOP | Operator stop/hold request |
| 2 | FAULT | Non-emergency fault (jam, guard open) |
| 3 | REBOOT | System reset (directly drives hardware reset logic) |

**Outputs (directly written to pins):**
| Bit | Signal | Description |
|-----|--------|-------------|
| 0 | GATE_SEL | Active packing lane (0 = Gate A, 1 = Gate B) |
| 1 | MOTOR_EN | Conveyor motor enable |
| 2 | ALARM | General alarm output |
| 3+ | STATUS | Debug/status bits (optional) |

### Option A: Memory-Mapped I/O

Specific addresses in the ROM address space are aliased to I/O ports instead of instructions. This approach requires additional decode logic but no new instructions.

**Implementation:**
- Address `0xE` (14): Reading fetches input port value instead of instruction
- Address `0xF` (15): Writing stores to output port instead of executing

**Trade-offs:**
- (+) No new instructions needed
- (+) Familiar paradigm (like x86 memory-mapped peripherals)
- (−) Consumes ROM addresses (only 14 usable for code)
- (−) Requires special fetch logic

### Option B: Dedicated I/O Instructions

Add explicit `IN` and `OUT` instructions to the ISA. This is the cleanest approach for educational purposes.

**New Instructions:**

| Opcode | Binary | Mnemonic | Format | Operation |
|--------|--------|----------|--------|-----------|
| — | `0111` | IN | I-Type variant | Rd = input_port |
| — | `0111` | OUT | I-Type variant | output_port = Rs |

See Section 4.8 for full instruction definitions.

**Trade-offs:**
- (+) Explicit and readable
- (+) Full 16 instructions available for code
- (+) Teaches I/O as a distinct concept
- (−) Consumes opcode space (but we have room)

### Option C: Register-Mapped I/O

Dedicate specific registers to I/O. Inputs appear in one register; outputs are driven from another.

**Implementation:**
- **Input Register (read-only view):** Reading R0 returns current input pin state
- **Output Register:** Writing R2 drives output pins

**Trade-offs:**
- (+) No new instructions or addressing modes
- (+) Uses existing MOV, AND, OR for I/O manipulation
- (+) Very simple hardware
- (−) Consumes general-purpose registers
- (−) Input register is read-only (writes ignored or cause SYS_ERR)

### Recommended Approach

**Option B (Dedicated I/O Instructions)** is recommended for most teams:
- Clear separation of concerns
- Explicit in assembly code
- Full register file available for computation
- Teaches embedded systems I/O concepts

---

## 4. Instruction Formats

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
┌────────┬──────────────────────┬─────────────────────┐
│ opcode │       unused         │      address        │
│  4 bit │        8 bit         │       4 bit         │
└────────┴──────────────────────┴─────────────────────┘
  [15:12]       [11:4]                [3:0]
```

**Fields:**
- `opcode` — Jump type
- `unused` — Reserved (should be set to 0)
- `address` — Target instruction address (0-15)

**Assembly syntax:** `JMP address` or `JZ address` or `JNZ address`

**Example:** `JNZ 5` — If R3 is not zero, jump to instruction at address 5

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
MOV R0 R2      ; R2 = 99
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
LDI R2 42      ; R2 = 42
```

---

### 4.5 Comparison Instructions

#### LT — Less Than
| | |
|---|---|
| **Opcode** | `1000` |
| **Format** | R-Type |
| **Syntax** | `LT Rs1 Rs2` |
| **Operation** | `R3 = (Rs1 < Rs2) ? 1 : 0` |
| **Flags** | **R3 is set** |
| **Description** | Compares Rs1 and Rs2 as signed two's complement values. Sets R3 to 1 if Rs1 < Rs2, otherwise 0. Rd field is ignored. |

**Example:**
```
LDI R0 5       ; R0 = 5
LDI R1 10      ; R1 = 10
LT R0 R1       ; R3 = 1 (because 5 < 10)
JNZ loop       ; Jump taken because R3 != 0
```

**Note:** To test "greater than", swap the operand order: `LT Rs2 Rs1` tests if Rs2 < Rs1, which is equivalent to Rs1 > Rs2.

#### EQ — Equal
| | |
|---|---|
| **Opcode** | `1001` |
| **Format** | R-Type |
| **Syntax** | `EQ Rs1 Rs2` |
| **Operation** | `R3 = (Rs1 == Rs2) ? 1 : 0` |
| **Flags** | **R3 is set** |
| **Description** | Compares Rs1 and Rs2 for equality. Sets R3 to 1 if equal, otherwise 0. Rd field is ignored. |

**Example:**
```
LDI R0 42
LDI R1 42
EQ R0 R1       ; R3 = 1 (equal)
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
| **Description** | Sets the program counter to the specified address (0-15). Execution continues from that instruction. |

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
| **Operation** | `if (R3 == 0) then PC = address` |
| **Flags** | Not affected |
| **Description** | Jumps to the specified address (0-15) if R3 is zero. Otherwise, continues to the next instruction. |

**Example:**
```
       EQ R0 R1    ; R3 = 1 if equal, 0 if not
       JZ skip     ; Jump if NOT equal (R3 == 0)
       ; ... code if equal ...
skip:  ; ... continues here ...
```

#### JNZ — Jump if Not Zero
| | |
|---|---|
| **Opcode** | `1101` |
| **Format** | J-Type |
| **Syntax** | `JNZ address` |
| **Operation** | `if (R3 != 0) then PC = address` |
| **Flags** | Not affected |
| **Description** | Jumps to the specified address (0-15) if R3 is not zero. Otherwise, continues to the next instruction. |

**Example:**
```
       LT R0 R1    ; R3 = 1 if R0 < R1
       JNZ less    ; Jump if R0 < R1
       ; ... code if R0 >= R1 ...
less:  ; ... code if R0 < R1 ...
```

---

### 4.7 Miscellaneous Instructions

#### (Reserved — Opcode 1110)

Opcode `1110` is **reserved** for team extensions. If your team implements a custom instruction (e.g., ADDI, NOT, INC, DEC), document it in your report. If not implemented, this opcode should trigger SYS_ERR as an illegal instruction.

**Extension ideas:**
- `ADDI Rd imm` — Add immediate to register
- `NOT Rs Rd` — Bitwise NOT
- `INC Rd` / `DEC Rd` — Increment/decrement
- `SWAPNIB Rd` — Swap nibbles (rotate by 4)

**Note:** If you need a no-operation, use `MOV R0 R0` (copies R0 to itself).

#### HALT — Halt Execution
| | |
|---|---|
| **Opcode** | `1111` |
| **Format** | — |
| **Syntax** | `HALT` |
| **Operation** | Stop CPU |
| **Flags** | Not affected |
| **Description** | Stops the CPU. The program counter no longer advances. Used to end programs. In the batch diverter context, HALT should only be reached on unrecoverable conditions; normal operation loops indefinitely. |

**Encoding:** `1111 0000 0000 0000` (all zeros after opcode)

---

### 5.8 I/O Instructions (Option B)

If your team selects **Option B: Dedicated I/O Instructions**, implement the following. If using Option A or C, skip this section.

#### IN — Read Input Port
| | |
|---|---|
| **Opcode** | Shares with MOV: `0111` with Rs2 = `11` |
| **Format** | R-Type (special) |
| **Syntax** | `IN Rd` |
| **Operation** | `Rd = input_port` |
| **Flags** | Not affected |
| **Description** | Reads the current state of the input port (ITEM_PULSE, STOP, FAULT, REBOOT) into register Rd. |

**Encoding:**
```
┌────────┬────────┬────────┬────────┬──────────────┐
│ opcode │   00   │   11   │   Rd   │   000000     │
│  0111  │  (ign) │ (mark) │  2 bit │    6 bit     │
└────────┴────────┴────────┴────────┴──────────────┘
```

The `Rs2 = 11` distinguishes IN from MOV (where Rs2 = 00).

**Example:**
```
IN R0          ; R0 = input port state
LDI R1 0x01    ; Mask for ITEM_PULSE (bit 0)
AND R0 R1 R0   ; R0 = 1 if item detected, else 0
```

#### OUT — Write Output Port
| | |
|---|---|
| **Opcode** | Shares with MOV: `0111` with Rs2 = `10` |
| **Format** | R-Type (special) |
| **Syntax** | `OUT Rs` |
| **Operation** | `output_port = Rs` |
| **Flags** | Not affected |
| **Description** | Writes the contents of Rs to the output port (GATE_SEL, MOTOR_EN, ALARM, STATUS). |

**Encoding:**
```
┌────────┬────────┬────────┬────────┬──────────────┐
│ opcode │   Rs   │   10   │   00   │   000000     │
│  0111  │  2 bit │ (mark) │  (ign) │    6 bit     │
└────────┴────────┴────────┴────────┴──────────────┘
```

The `Rs2 = 10` distinguishes OUT from MOV and IN.

**Example:**
```
LDI R2 0x02    ; MOTOR_EN = 1, GATE_SEL = 0 (Gate A)
OUT R2         ; Write to output port
```

### I/O Encoding Summary (Option B)

| Rs2 | Instruction | Operation |
|-----|-------------|-----------|
| `00` | MOV Rs1 Rd | Rd = Rs1 |
| `01` | (reserved) | — |
| `10` | OUT Rs1 | output_port = Rs1 |
| `11` | IN Rd | Rd = input_port |

**Design Note:** By overloading the MOV opcode with Rs2 variants, we avoid consuming additional opcodes while providing clean I/O semantics. The decoder checks Rs2 to select between register move and port operations.

---

## 6. Instruction Encoding Summary

| Opcode | Binary | Mnemonic | Format | Operation |
|--------|--------|----------|--------|-----------|
| 0 | `0000` | ADD | R | Rd = Rs1 + Rs2 |
| 1 | `0001` | SUB | R | Rd = Rs1 - Rs2 |
| 2 | `0010` | AND | R | Rd = Rs1 & Rs2 |
| 3 | `0011` | OR | R | Rd = Rs1 \| Rs2 |
| 4 | `0100` | XOR | R | Rd = Rs1 ^ Rs2 |
| 5 | `0101` | SHL | R | Rd = Rs1 << Rs2 |
| 6 | `0110` | SHR | R | Rd = Rs1 >> Rs2 |
| 7 | `0111` | MOV | R | Rd = Rs1 (Rs2=00) |
| 7 | `0111` | OUT | R | output = Rs1 (Rs2=10) † |
| 7 | `0111` | IN | R | Rd = input (Rs2=11) † |
| 8 | `1000` | LT | R | R3 = (Rs1 < Rs2) |
| 9 | `1001` | EQ | R | R3 = (Rs1 == Rs2) |
| 10 | `1010` | LDI | I | Rd = immediate |
| 11 | `1011` | JMP | J | PC = address |
| 12 | `1100` | JZ | J | if R3==0: PC = addr |
| 13 | `1101` | JNZ | J | if R3!=0: PC = addr |
| 14 | `1110` | — | — | Reserved (extension or SYS_ERR) |
| 15 | `1111` | HALT | — | Stop execution |

† Option B only. See Section 5.8 for I/O instruction details.

---

## 7. Binary Encoding Examples

### Example 1: ADD R0 R1 R2

```
ADD  R0   R1   R2   unused
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
JNZ  unused        address(5)
1101  00000000     0101

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

### Example 5: IN R0 (Option B)

```
IN   --   11   R0   unused
0111  00   11   00   000000

Binary: 0111 0011 0000 0000
Hex:    0x7300
```

### Example 6: OUT R2 (Option B)

```
OUT  R2   10   --   unused
0111  10   10   00   000000

Binary: 0111 1010 0000 0000
Hex:    0x7A00
```

---

## 8. Program Memory

The EE8 uses a ROM (Read-Only Memory) to store programs.

| Parameter | Value |
|-----------|-------|
| Word size | 16 bits (one instruction) |
| Address width | 4 bits |
| Capacity | 16 words |
| Address range | 0-15 (0x0-0xF) |

### Program Counter (PC)
- 4-bit register
- Initializes to 0 on reset
- Increments by 1 after each instruction (unless jump taken)
- Wraps around from 15 to 0

### Loading Programs

Students will build two ROM modules:
1. **External ROM** - Instructor-provided test programs (pre-loaded)
2. **Internal ROM** - Student-built program memory

A **LOAD signal** transfers the test program from external ROM to internal ROM before execution begins.

### Fetch-Decode-Execute Cycle
1. **Fetch:** Read instruction from ROM at address PC
2. **Decode:** Extract opcode and operands
3. **Execute:** Perform operation
4. **Update PC:** PC = PC + 1 (or jump target if branch taken)

---

## 9. Timing and Clocking

The CPU operates on a single clock signal in a **single-cycle architecture**.

| Mode | Description |
|------|-------------|
| **Step mode** | Manual clock button for debugging — one instruction per press |
| **Run mode** | Continuous clock signal from oscillator |

### Clock Phases (single-cycle)
On each rising clock edge:
1. Current instruction executes (fetch, decode, execute happen combinationally)
2. Results written to registers
3. PC updates

All operations are **atomic** — each instruction completes in a single clock cycle.

**Design Note:** Single-cycle architecture is simpler to design and understand than pipelined CPUs, making it ideal for educational purposes. The trade-off is that all instructions take the same time, even if some could be faster.

---

## 10. Assembly Language Syntax

### Comments
```
; This is a comment
ADD R0 R1 R2    ; Inline comment
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

## 11. Example Programs

### 11.1 Basic Batch Diverter (Option B)

```
; Simple batch diverter: A=3 items to Gate A, B=2 items to Gate B
; Uses Option B I/O instructions
; Uses 14 instructions

0:  LDI R0 3           ; R0 = count A (3 items to Gate A)
1:  LDI R1 0x02        ; R1 = output: MOTOR_EN=1, GATE_SEL=0 (Gate A)
2:  OUT R1             ; Enable motor, select Gate A

; --- Gate A loop ---
3:  IN R2              ; Read inputs
4:  LDI R3 0x01        ; Mask for ITEM_PULSE (bit 0)
5:  AND R2 R3 R2       ; Isolate ITEM_PULSE
6:  JZ 3               ; No pulse? Keep polling
7:  LDI R3 1           ; Decrement value
8:  SUB R0 R3 R0       ; R0 = R0 - 1
9:  JNZ 3              ; More items? Keep counting

; --- Switch to Gate B ---
10: LDI R0 2           ; R0 = count B (2 items to Gate B)
11: LDI R1 0x03        ; R1 = output: MOTOR_EN=1, GATE_SEL=1 (Gate B)
12: OUT R1             ; Select Gate B
13: JMP 3              ; Reuse counting loop (counts down R0)

; Note: After B items, R0=0, falls through to addr 10, reloads A=2
; This creates a 3-2-2-2... pattern. Full A/B alternation needs 16 insns.
14: NOP
15: HALT
```

### 11.2 Full Batch Diverter with Alternation

```
; Full batch diverter: A items to Gate A, B items to Gate B, repeat
; Uses all 16 instructions
; A=5, B=3 (hardcoded in ROM)

0:  LDI R0 5           ; R0 = count A
1:  LDI R2 0x02        ; Output: MOTOR=1, GATE=A
2:  OUT R2             ; Apply output

; --- Counting loop (shared) ---
3:  IN R1              ; Read inputs
4:  LDI R3 0x01        ; ITEM_PULSE mask
5:  AND R1 R3 R1       ; Isolate pulse
6:  JZ 3               ; No pulse? Poll again
7:  LDI R3 1
8:  SUB R0 R3 R0       ; Decrement counter
9:  JNZ 3              ; More items? Continue

; --- Toggle gate ---
10: LDI R3 0x01        ; Gate toggle mask
11: XOR R2 R3 R2       ; Flip GATE_SEL bit
12: OUT R2             ; Update output
13: LDI R0 3           ; Load count B (or A if toggled back)
14: JMP 3              ; Back to counting

15: HALT               ; Never reached in normal operation
```

**Note:** This simplified version uses fixed counts. A full implementation with distinct A and B counts requires careful ROM optimization or an extension approach (see project spec).

### 11.3 Arithmetic Example: Add Two Numbers

```
; Adds 25 + 17, stores result in R2
; Uses 4 instructions
        LDI R0 25
        LDI R1 17
        ADD R0 R1 R2   ; R2 = 42
        HALT
```

### 11.4 Find Maximum of Two Numbers

```
; Finds max of R0 and R1, stores in R2
; Uses 8 instructions
        LDI R0 45
        LDI R1 72
        LT R0 R1       ; R3 = 1 if R0 < R1
        JNZ r1_bigger  ; If R0 < R1, jump
        MOV R0 R2      ; R0 is bigger or equal
        JMP done
r1_bigger:
        MOV R1 R2      ; R1 is bigger
done:   HALT
```

### 11.5 Polling Input Example

```
; Wait for ITEM_PULSE, then set ALARM
; Demonstrates I/O polling pattern

0:  LDI R2 0x02        ; MOTOR_EN=1, ALARM=0
1:  OUT R2             ; Enable motor
2:  IN R0              ; Read inputs
3:  LDI R1 0x01        ; ITEM_PULSE mask
4:  AND R0 R1 R0       ; Isolate bit 0
5:  JZ 2               ; No pulse? Keep polling
6:  LDI R2 0x04        ; ALARM=1, MOTOR=0
7:  OUT R2             ; Sound alarm
8:  HALT
```

---

## Appendix A: Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│                    EE8 CPU Quick Reference              │
├─────────────────────────────────────────────────────────┤
│ REGISTERS                                               │
│   R0, R1    General purpose                             │
│   R2        General purpose                             │
│   R3        General purpose + comparison results        │
├─────────────────────────────────────────────────────────┤
│ ARITHMETIC          │ BITWISE                           │
│   ADD Rs1 Rs2 Rd    │   AND Rs1 Rs2 Rd                  │
│   SUB Rs1 Rs2 Rd    │   OR  Rs1 Rs2 Rd                  │
│                     │   XOR Rs1 Rs2 Rd                  │
├─────────────────────┼───────────────────────────────────┤
│ SHIFT               │ COMPARE (sets R3)                 │
│   SHL Rs1 Rs2 Rd    │   LT Rs1 Rs2  (R3 = Rs1 < Rs2)    │
│   SHR Rs1 Rs2 Rd    │   EQ Rs1 Rs2  (R3 = Rs1 == Rs2)   │
├─────────────────────┴───────────────────────────────────┤
│ DATA MOVEMENT                                           │
│   MOV Rs Rd         Copy register                       │
│   LDI Rd imm        Load immediate (0-255)              │
│   IN Rd             Read input port (Option B)          │
│   OUT Rs            Write output port (Option B)        │
├─────────────────────────────────────────────────────────┤
│ CONTROL FLOW        (address range: 0-15)               │
│   JMP addr          Unconditional jump                  │
│   JZ  addr          Jump if R3 == 0                     │
│   JNZ addr          Jump if R3 != 0                     │
├─────────────────────────────────────────────────────────┤
│ MISC                                                    │
│   HALT              Stop execution                      │
│   (opcode 1110)     Reserved for extensions             │
├─────────────────────────────────────────────────────────┤
│ I/O PORT BITS (Batch Diverter)                          │
│   Input:  [0]=ITEM_PULSE [1]=STOP [2]=FAULT [3]=REBOOT  │
│   Output: [0]=GATE_SEL [1]=MOTOR_EN [2]=ALARM [3+]=STAT │
└─────────────────────────────────────────────────────────┘

Memory: 16 instructions (addresses 0-F)
PC wraps from 15 → 0
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
       0110  SHR      1110  (reserved)
       0111  MOV/IN/OUT   1111  HALT

  MOV/IN/OUT disambiguation (opcode 0111):
       Rs2=00  MOV Rs1 Rd
       Rs2=10  OUT Rs1
       Rs2=11  IN Rd
```

---

## Appendix C: I/O Interface Options Summary

| Option | Mechanism | Pros | Cons |
|--------|-----------|------|------|
| A | Memory-mapped | No new instructions | Loses ROM addresses |
| B | IN/OUT instructions | Clean, explicit | Uses opcode space |
| C | Register-mapped | Simplest hardware | Loses registers |

**Recommended:** Option B for clarity and full resource availability.

---

## Appendix D: Changes from Previous Versions

**Version 3.0 updates (I/O and batch diverter):**
- Added I/O interface section (Options A, B, C)
- Added IN and OUT instructions (Option B) via MOV opcode overloading
- Renamed RO→R2, RF→R3 for uniformity (all registers now general-purpose)
- Removed NOP (opcode 1110 now reserved for team extensions)
- Updated examples for batch diverter scenario
- Added I/O port bit assignments for station signals
- Aligned with EG2300 project specification

**Version 2.0 updates (4-bit addressing):**
- Reduced program memory from 256 to 16 instructions
- Changed PC from 8-bit to 4-bit counter
- Updated J-type format: address field now [3:0] (4 bits)
- All jump/branch addresses now 0-15 range
- Added design rationale for comparison register approach

---

*End of EE8 CPU ISA Specification*
