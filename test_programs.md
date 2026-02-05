# EE8 CPU Test Programs

## Instruction Encoding Reference
```
Format: [15:12]=opcode [11:10]=rs1 [9:8]=rs2 [7:6]=rd [5:0]=unused
        [7:0]=immediate (for LDI, JMP, JZ, JNZ)

Registers: R0=00, R1=01, RO=10, RF=11

Opcodes:
  0=ADD   1=SUB   2=AND   3=OR    4=XOR
  5=SHL   6=SHR   7=MOV   8=LT    9=EQ
  A=LDI   B=JMP   C=JZ    D=JNZ   E=NOP   F=HALT
```

---

## Test 1: Subtraction
**Expected Result: RO = 0x0D (13)**
```
0: A014  LDI R0, 20      ; R0 = 20
1: A407  LDI R1, 7       ; R1 = 7
2: 1180  SUB R0, R1, RO  ; RO = 20 - 7 = 13
3: F000  HALT
```
ROM contents: `a014 a407 1180 f000`

---

## Test 2: Logical AND
**Expected Result: RO = 0x03**
```
0: A00F  LDI R0, 0x0F    ; R0 = 0000_1111
1: A4F3  LDI R1, 0xF3    ; R1 = 1111_0011
2: 2180  AND R0, R1, RO  ; RO = 0x0F & 0xF3 = 0x03
3: F000  HALT
```
ROM contents: `a00f a4f3 2180 f000`

---

## Test 3: Logical OR
**Expected Result: RO = 0xFF**
```
0: A00F  LDI R0, 0x0F    ; R0 = 0000_1111
1: A4F0  LDI R1, 0xF0    ; R1 = 1111_0000
2: 3180  OR R0, R1, RO   ; RO = 0x0F | 0xF0 = 0xFF
3: F000  HALT
```
ROM contents: `a00f a4f0 3180 f000`

---

## Test 4: Logical XOR
**Expected Result: RO = 0x96**
```
0: A0AA  LDI R0, 0xAA    ; R0 = 1010_1010
1: A43C  LDI R1, 0x3C    ; R1 = 0011_1100
2: 4180  XOR R0, R1, RO  ; RO = 0xAA ^ 0x3C = 0x96
3: F000  HALT
```
ROM contents: `a0aa a43c 4180 f000`

---

## Test 5: Shift Left
**Expected Result: RO = 0x10 (16)**
```
0: A001  LDI R0, 1       ; R0 = 1
1: A404  LDI R1, 4       ; R1 = 4 (shift amount)
2: 5180  SHL R0, R1, RO  ; RO = 1 << 4 = 16
3: F000  HALT
```
ROM contents: `a001 a404 5180 f000`

---

## Test 6: Shift Right
**Expected Result: RO = 0x04**
```
0: A040  LDI R0, 64      ; R0 = 64 = 0x40
1: A404  LDI R1, 4       ; R1 = 4 (shift amount)
2: 6180  SHR R0, R1, RO  ; RO = 64 >> 4 = 4
3: F000  HALT
```
ROM contents: `a040 a404 6180 f000`

---

## Test 7: Less Than Comparison (true)
**Expected Result: RO = 0x01**
```
0: A005  LDI R0, 5       ; R0 = 5
1: A40A  LDI R1, 10      ; R1 = 10
2: 8100  LT R0, R1       ; RF = (5 < 10) = 1
3: 7C80  MOV RF, _, RO   ; RO = RF = 1
4: F000  HALT
```
ROM contents: `a005 a40a 8100 7c80 f000`

---

## Test 8: Less Than Comparison (false)
**Expected Result: RO = 0x00**
```
0: A00A  LDI R0, 10      ; R0 = 10
1: A405  LDI R1, 5       ; R1 = 5
2: 8100  LT R0, R1       ; RF = (10 < 5) = 0
3: 7C80  MOV RF, _, RO   ; RO = RF = 0
4: F000  HALT
```
ROM contents: `a00a a405 8100 7c80 f000`

---

## Test 9: Equality Comparison (true)
**Expected Result: RO = 0x01**
```
0: A007  LDI R0, 7       ; R0 = 7
1: A407  LDI R1, 7       ; R1 = 7
2: 9100  EQ R0, R1       ; RF = (7 == 7) = 1
3: 7C80  MOV RF, _, RO   ; RO = RF = 1
4: F000  HALT
```
ROM contents: `a007 a407 9100 7c80 f000`

---

## Test 10: Unconditional Jump
**Expected Result: RO = 0xAA (instruction at addr 2 skipped)**
```
0: A0AA  LDI R0, 0xAA    ; R0 = 0xAA
1: B003  JMP 3           ; jump to addr 3
2: A055  LDI R0, 0x55    ; SKIPPED
3: 7080  MOV R0, _, RO   ; RO = R0 = 0xAA
4: F000  HALT
```
ROM contents: `a0aa b003 a055 7080 f000`

---

## Test 11: Jump if Zero (JZ) - branch taken
**Expected Result: RO = 0xAA**
```
0: A005  LDI R0, 5       ; R0 = 5
1: A40A  LDI R1, 10      ; R1 = 10
2: 9100  EQ R0, R1       ; RF = (5 == 10) = 0
3: C006  JZ 6            ; RF=0, so jump to addr 6
4: A8BB  LDI RO, 0xBB    ; SKIPPED
5: B007  JMP 7           ; SKIPPED
6: A8AA  LDI RO, 0xAA    ; RO = 0xAA
7: F000  HALT
```
ROM contents: `a005 a40a 9100 c006 a8bb b007 a8aa f000`

---

## Test 12: Jump if Not Zero (JNZ) - branch taken
**Expected Result: RO = 0xAA**
```
0: A007  LDI R0, 7       ; R0 = 7
1: A407  LDI R1, 7       ; R1 = 7
2: 9100  EQ R0, R1       ; RF = (7 == 7) = 1
3: D006  JNZ 6           ; RF!=0, so jump to addr 6
4: A8BB  LDI RO, 0xBB    ; SKIPPED
5: B007  JMP 7           ; SKIPPED
6: A8AA  LDI RO, 0xAA    ; RO = 0xAA
7: F000  HALT
```
ROM contents: `a007 a407 9100 d006 a8bb b007 a8aa f000`

---

## Test 13: Countdown Loop
**Expected Result: RO = 0x00 (counts down from 5 to 0)**
```
0: A005  LDI R0, 5       ; R0 = 5 (counter)
1: A401  LDI R1, 1       ; R1 = 1 (decrement)
loop:
2: 7080  MOV R0, _, RO   ; RO = R0 (display counter)
3: 1100  SUB R0, R1, R0  ; R0 = R0 - 1
4: AC00  LDI RF, 0       ; RF = 0 (for comparison)
5: 9300  EQ R0, RF       ; RF = (R0 == 0)?
6: C002  JZ 2            ; if RF=0 (R0 != 0), loop back
7: 7080  MOV R0, _, RO   ; RO = R0 = 0
8: F000  HALT
```
ROM contents: `a005 a401 7080 1100 ac00 9300 c002 7080 f000`

Watch RO decrement: 5 -> 4 -> 3 -> 2 -> 1 -> 0

---

## Test 14: Fibonacci Sequence
**Expected Result: RO = 0x03**
Computes a few Fibonacci iterations: 0, 1, 1, 2, 3
```
0: A001  LDI R0, 1       ; a = 1
1: A400  LDI R1, 0       ; b = 0
2: 0040  ADD R0, R1, R1  ; b = a + b (b=1)
3: 0080  ADD R0, R1, RO  ; RO = a + b = 2, temp store
4: 7400  MOV R1, _, R0   ; a = b (a=1)
5: 7840  MOV RO, _, R1   ; b = RO (b=2)
6: 0080  ADD R0, R1, RO  ; RO = a + b = 3
7: F000  HALT
```
ROM contents: `a001 a400 0040 0080 7400 7840 0080 f000`

---

## Test 15: Multiply by repeated addition (3 x 4 = 12)
**Expected Result: RO = 0x0C (12)**
```
0: A003  LDI R0, 3       ; R0 = 3 (multiplicand)
1: A404  LDI R1, 4       ; R1 = 4 (counter)
2: A800  LDI RO, 0       ; RO = 0 (result)
loop:
3: 0880  ADD RO, R0, RO  ; RO = RO + 3
4: AC01  LDI RF, 1       ; RF = 1 (for decrement)
5: 1740  SUB R1, RF, R1  ; R1 = R1 - 1
6: AC00  LDI RF, 0       ; RF = 0 (for comparison)
7: 9700  EQ R1, RF       ; RF = (R1 == 0)
8: C003  JZ 3            ; if RF=0 (R1 != 0), loop
9: F000  HALT
```
ROM contents: `a003 a404 a800 0880 ac01 1740 ac00 9700 c003 f000`

---

## How to Load a Test Program

In Logisim Evolution, edit the ROM component in the ROM subcircuit:

1. Right-click the ROM → "Edit Contents..."
2. Clear existing data
3. Enter the hex values from "ROM contents" above
4. Each value is a 16-bit instruction

Or modify the .circ file directly - find the `<a name="contents">` section in the ROM circuit.
