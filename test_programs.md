# EE8 CPU Test Programs (ISA v4.0)

## Instruction Encoding Reference
```
R-Type: [15:12]=opcode [11:10]=Rs1 [9:8]=Rs2 [7:6]=Rd [5:0]=unused
I-Type: [15:12]=opcode [11:10]=unused [9:8]=Rd  [7:0]=immediate
J-Type: [15:12]=opcode [11:10]=Rcond  [9:4]=unused [3:0]=address

Registers: R0=00, R1=01, R2=10, R3=11

Opcodes:
  0=ADD   1=SUB   2=AND   3=OR    4=XOR
  5=SHL   6=SHR   7=MOV   8=LT    9=EQ
  A=LDI   B=JMP   C=JZ    D=JNZ   E=(reserved)   F=HALT

MOV/IN/OUT (opcode 0111) disambiguation via Rs2:
  Rs2=00: MOV   Rs2=01: (SYS_ERR)   Rs2=10: OUT   Rs2=11: IN
```

---

## Test 1: Subtraction
**Expected Result: R2 = 0x0D (13)**
```
0: A014  LDI R0, 20      ; R0 = 20
1: A107  LDI R1, 7       ; R1 = 7
2: 1180  SUB R0, R1, R2  ; R2 = 20 - 7 = 13
3: F000  HALT
```
ROM contents: `a014 a107 1180 f000`

---

## Test 2: Logical AND
**Expected Result: R2 = 0x03**
```
0: A00F  LDI R0, 0x0F    ; R0 = 0000_1111
1: A1F3  LDI R1, 0xF3    ; R1 = 1111_0011
2: 2180  AND R0, R1, R2  ; R2 = 0x0F & 0xF3 = 0x03
3: F000  HALT
```
ROM contents: `a00f a1f3 2180 f000`

---

## Test 3: Logical OR
**Expected Result: R2 = 0xFF**
```
0: A00F  LDI R0, 0x0F    ; R0 = 0000_1111
1: A1F0  LDI R1, 0xF0    ; R1 = 1111_0000
2: 3180  OR R0, R1, R2   ; R2 = 0x0F | 0xF0 = 0xFF
3: F000  HALT
```
ROM contents: `a00f a1f0 3180 f000`

---

## Test 4: Logical XOR
**Expected Result: R2 = 0x96**
```
0: A0AA  LDI R0, 0xAA    ; R0 = 1010_1010
1: A13C  LDI R1, 0x3C    ; R1 = 0011_1100
2: 4180  XOR R0, R1, R2  ; R2 = 0xAA ^ 0x3C = 0x96
3: F000  HALT
```
ROM contents: `a0aa a13c 4180 f000`

---

## Test 5: Shift Left
**Expected Result: R2 = 0x10 (16)**
```
0: A001  LDI R0, 1       ; R0 = 1
1: A104  LDI R1, 4       ; R1 = 4 (shift amount)
2: 5180  SHL R0, R1, R2  ; R2 = 1 << 4 = 16
3: F000  HALT
```
ROM contents: `a001 a104 5180 f000`

---

## Test 6: Shift Right
**Expected Result: R2 = 0x04**
```
0: A040  LDI R0, 64      ; R0 = 64 = 0x40
1: A104  LDI R1, 4       ; R1 = 4 (shift amount)
2: 6180  SHR R0, R1, R2  ; R2 = 64 >> 4 = 4
3: F000  HALT
```
ROM contents: `a040 a104 6180 f000`

---

## Test 7: Less Than Comparison (true)
**Expected Result: R2 = 0x01**
```
0: A005  LDI R0, 5       ; R0 = 5
1: A10A  LDI R1, 10      ; R1 = 10
2: 8100  LT R0, R1       ; R3 = (5 < 10) = 1
3: 7C80  MOV R3, R2      ; R2 = R3 = 1
4: F000  HALT
```
ROM contents: `a005 a10a 8100 7c80 f000`

---

## Test 8: Less Than Comparison (false)
**Expected Result: R2 = 0x00**
```
0: A00A  LDI R0, 10      ; R0 = 10
1: A105  LDI R1, 5       ; R1 = 5
2: 8100  LT R0, R1       ; R3 = (10 < 5) = 0
3: 7C80  MOV R3, R2      ; R2 = R3 = 0
4: F000  HALT
```
ROM contents: `a00a a105 8100 7c80 f000`

---

## Test 9: Equality Comparison (true)
**Expected Result: R2 = 0x01**
```
0: A007  LDI R0, 7       ; R0 = 7
1: A107  LDI R1, 7       ; R1 = 7
2: 9100  EQ R0, R1       ; R3 = (7 == 7) = 1
3: 7C80  MOV R3, R2      ; R2 = R3 = 1
4: F000  HALT
```
ROM contents: `a007 a107 9100 7c80 f000`

---

## Test 10: Unconditional Jump
**Expected Result: R2 = 0xAA (instruction at addr 2 skipped)**
```
0: A0AA  LDI R0, 0xAA    ; R0 = 0xAA
1: B003  JMP 3           ; jump to addr 3
2: A055  LDI R0, 0x55    ; SKIPPED
3: 7080  MOV R0, R2      ; R2 = R0 = 0xAA
4: F000  HALT
```
ROM contents: `a0aa b003 a055 7080 f000`

---

## Test 11: Jump if Zero (JZ) — branch taken
**Expected Result: R2 = 0xAA**
```
0: A005  LDI R0, 5       ; R0 = 5
1: A10A  LDI R1, 10      ; R1 = 10
2: 9100  EQ R0, R1       ; R3 = (5 == 10) = 0
3: CC06  JZ R3, 6        ; R3=0, so jump to addr 6
4: A2BB  LDI R2, 0xBB    ; SKIPPED
5: B007  JMP 7           ; SKIPPED
6: A2AA  LDI R2, 0xAA    ; R2 = 0xAA
7: F000  HALT
```
ROM contents: `a005 a10a 9100 cc06 a2bb b007 a2aa f000`

---

## Test 12: Jump if Not Zero (JNZ) — branch taken
**Expected Result: R2 = 0xAA**
```
0: A007  LDI R0, 7       ; R0 = 7
1: A107  LDI R1, 7       ; R1 = 7
2: 9100  EQ R0, R1       ; R3 = (7 == 7) = 1
3: DC06  JNZ R3, 6       ; R3!=0, so jump to addr 6
4: A2BB  LDI R2, 0xBB    ; SKIPPED
5: B007  JMP 7           ; SKIPPED
6: A2AA  LDI R2, 0xAA    ; R2 = 0xAA
7: F000  HALT
```
ROM contents: `a007 a107 9100 dc06 a2bb b007 a2aa f000`

---

## Test 13: Countdown Loop
**Expected Result: R2 = 0x00 (counts down from 5 to 0)**

Uses JNZ with Rcond=R0 to branch directly on the counter register — no comparison instruction needed.

```
0: A005  LDI R0, 5       ; R0 = 5 (counter)
1: A101  LDI R1, 1       ; R1 = 1 (decrement constant)
loop:
2: 7080  MOV R0, R2      ; R2 = R0 (display counter)
3: 1100  SUB R0, R1, R0  ; R0 = R0 - 1
4: D002  JNZ R0, 2       ; if R0 != 0, loop back (Rcond=R0)
5: 7080  MOV R0, R2      ; R2 = R0 = 0
6: F000  HALT
```
ROM contents: `a005 a101 7080 1100 d002 7080 f000`

Watch R2 decrement: 5 -> 4 -> 3 -> 2 -> 1 -> 0

---

## Test 14: Fibonacci Sequence
**Expected Result: R2 = 0x03**

Computes a few Fibonacci iterations: 0, 1, 1, 2, 3

```
0: A001  LDI R0, 1       ; a = 1
1: A100  LDI R1, 0       ; b = 0
2: 0140  ADD R0, R1, R1  ; b = a + b (0+1=1)
3: 0180  ADD R0, R1, R2  ; R2 = a + b = 1+1 = 2 (temp)
4: 7400  MOV R1, R0      ; a = b (a=1)
5: 7840  MOV R2, R1      ; b = temp (b=2)
6: 0180  ADD R0, R1, R2  ; R2 = a + b = 1+2 = 3
7: F000  HALT
```
ROM contents: `a001 a100 0140 0180 7400 7840 0180 f000`

---

## Test 15: Multiply by Repeated Addition (3 x 4 = 12)
**Expected Result: R2 = 0x0C (12)**

Uses JNZ with Rcond=R1 to branch directly on the counter register.

```
0: A003  LDI R0, 3       ; R0 = 3 (multiplicand)
1: A104  LDI R1, 4       ; R1 = 4 (counter)
2: A200  LDI R2, 0       ; R2 = 0 (accumulator)
loop:
3: 0880  ADD R2, R0, R2  ; R2 = R2 + 3
4: A301  LDI R3, 1       ; R3 = 1 (for decrement)
5: 1740  SUB R1, R3, R1  ; R1 = R1 - 1
6: D403  JNZ R1, 3       ; if R1 != 0, loop (Rcond=R1)
7: F000  HALT
```
ROM contents: `a003 a104 a200 0880 a301 1740 d403 f000`

---

## How to Load a Test Program

In Logisim Evolution, edit the ROM component in the ROM subcircuit:

1. Right-click the ROM -> "Edit Contents..."
2. Clear existing data
3. Enter the hex values from "ROM contents" above
4. Each value is a 16-bit instruction
5. ROM has 16 words (addresses 0-F)

Or modify the .circ file directly - find the `<a name="contents">` section in the ROM circuit.
