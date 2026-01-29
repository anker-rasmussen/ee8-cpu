# EE8 CPU — Weekly Lesson Plan

**Module:** Engineering Systems
**Level:** Second Year Electrical Engineering
**Duration:** 10 Weeks
**Tool:** Logisim Evolution

---

## Course Overview

Students will design and implement a complete 8-bit CPU in Logisim, building each component incrementally through weekly tutorials. The final coursework is the integration of all components into a working CPU that can execute programs from ROM.

### Prerequisites
- Combinational logic gates (AND, OR, NOT, XOR, NAND, NOR)
- 4-bit adder/subtractor circuit
- 7-segment display decoder
- Basic Logisim proficiency (creating subcircuits, tunnels, splitters)

### Learning Outcomes
By the end of this module, students will be able to:
1. Design sequential logic circuits using D flip-flops and registers
2. Construct an Arithmetic Logic Unit (ALU) with multiple operations
3. Implement instruction decoding and control logic
4. Integrate components into a functioning CPU
5. Write and debug simple assembly programs

---

## Weekly Breakdown

---

### Week 1: Introduction and Review

**Topics:**
- Course overview and CPU architecture introduction
- Review of combinational logic
- Introduction to the EE8 CPU architecture

**Lecture Content:**
- What is a CPU? (Fetch-Decode-Execute cycle)
- Von Neumann vs Harvard architecture (EE8 uses Harvard-like: separate instruction ROM)
- Overview of EE8 components: Registers, ALU, Control Unit, Program Counter
- The instruction set (high-level overview)

**Tutorial: Review Circuit**
Build a combinational circuit refresher:
- 8-bit 2-to-1 multiplexer (will be used extensively later)
- 8-bit 4-to-1 multiplexer (for register selection)

**Deliverable:**
- `mux_2to1_8bit.circ`
- `mux_4to1_8bit.circ`

**Key Concepts:**
- Bit slicing and bus notation
- Creating reusable subcircuits in Logisim
- Splitters for extracting/combining bits

---

### Week 2: Memory Elements — Latches and Flip-Flops

**Topics:**
- Sequential vs combinational logic
- SR latch, D latch, D flip-flop
- Edge-triggered vs level-triggered
- Setup and hold time (conceptual)

**Lecture Content:**
- Why do we need memory? (State retention between clock cycles)
- SR latch from NAND gates — the fundamental memory cell
- D latch — data input, enable signal
- D flip-flop — edge-triggered, clock signal
- Timing diagrams

**Tutorial: Build Memory Elements**

**Part A:** D Latch (level-triggered)
```
Inputs:  D (data), E (enable)
Output:  Q
Behavior: When E=1, Q follows D. When E=0, Q holds.
```

**Part B:** D Flip-Flop (edge-triggered)
```
Inputs:  D (data), CLK (clock)
Output:  Q
Behavior: Q updates to D only on rising edge of CLK.
```

**Part C:** D Flip-Flop with Enable
```
Inputs:  D, CLK, EN (enable)
Output:  Q
Behavior: Q updates to D on rising CLK edge, but only if EN=1.
```

**Deliverable:**
- `d_latch.circ`
- `d_flipflop.circ`
- `d_flipflop_enable.circ`

**Discussion Questions:**
- Why do CPUs use edge-triggered flip-flops rather than latches?
- What happens if setup time is violated?

---

### Week 3: Registers — PIPO and Register File

**Topics:**
- Parallel In, Parallel Out (PIPO) registers
- Multi-bit registers from flip-flops
- Register file design

**Lecture Content:**
- Building an 8-bit register from D flip-flops
- Enable and clear signals
- Register file: multiple registers with addressing
- Read ports vs write ports
- The EE8 register set: R0, R1, RO, RF

**Tutorial: Build Register Components**

**Part A:** 8-bit Register
```
Inputs:  D[7:0], CLK, EN, CLR
Output:  Q[7:0]
Behavior: On rising CLK, if EN=1, Q←D. If CLR=1, Q←0.
```

**Part B:** 4-Register File (Read)
```
Inputs:  sel_A[1:0], sel_B[1:0]
Outputs: A[7:0], B[7:0]
Behavior: A = register[sel_A], B = register[sel_B]
          (Two simultaneous read ports)
```

**Part C:** 4-Register File (Write)
```
Inputs:  D[7:0], sel_W[1:0], WE, CLK
Behavior: On rising CLK, if WE=1, register[sel_W] ← D
```

**Part D:** Complete Register File
Combine read and write functionality:
- 2 read ports (for Rs1 and Rs2)
- 1 write port (for Rd)
- 4 registers (R0, R1, RO, RF)
- RO output directly connected to 7-segment display

**Deliverable:**
- `register_8bit.circ`
- `register_file.circ` (complete with 7-seg on RO)

**Key Insight:**
The register file is the "scratch paper" of the CPU — all computation results pass through here.

---

### Week 4: ALU Part 1 — Adder and Subtractor

**Topics:**
- Full adder review
- 8-bit ripple carry adder
- Two's complement subtraction
- Adder/Subtractor combination

**Lecture Content:**
- Review: Half adder, full adder, carry propagation
- Extending 4-bit adder knowledge to 8 bits
- Two's complement: why it makes subtraction easy
- A - B = A + (~B) + 1
- Overflow detection (optional/advanced)

**Tutorial: Build Adder/Subtractor**

**Part A:** 8-bit Ripple Carry Adder
```
Inputs:  A[7:0], B[7:0], Cin
Outputs: S[7:0], Cout
```

**Part B:** 8-bit Subtractor
Using the adder with inverted B and Cin=1:
```
Inputs:  A[7:0], B[7:0]
Output:  D[7:0] = A - B
```

**Part C:** Combined Adder/Subtractor
```
Inputs:  A[7:0], B[7:0], SUB (0=add, 1=subtract)
Output:  R[7:0]
         Cout (carry/borrow)
```
Use XOR gates to conditionally invert B.

**Deliverable:**
- `adder_8bit.circ`
- `adder_subtractor_8bit.circ`

**Testing:**
| A | B | SUB | Expected R |
|---|---|-----|------------|
| 10 | 5 | 0 | 15 |
| 10 | 5 | 1 | 5 |
| 5 | 10 | 1 | -5 (251 unsigned) |
| 127 | 1 | 0 | 128 (-128 signed, overflow) |

---

### Week 5: ALU Part 2 — Bitwise and Shift Operations

**Topics:**
- Bitwise AND, OR, XOR
- Logical shift left and right
- Barrel shifter (simplified)

**Lecture Content:**
- Bitwise operations: bit-by-bit application
- Use cases: masking, setting/clearing bits, flags
- Shift operations: multiplication/division by powers of 2
- Logical vs arithmetic shift (EE8 uses logical)
- Barrel shifter concept: shift by variable amount

**Tutorial: Build Bitwise and Shift Units**

**Part A:** 8-bit Bitwise Unit
```
Inputs:  A[7:0], B[7:0], op[1:0]
Output:  R[7:0]

op=00: R = A AND B
op=01: R = A OR B
op=10: R = A XOR B
op=11: (reserved/passthrough A)
```

**Part B:** 8-bit Left Shifter
```
Inputs:  A[7:0], shamt[2:0] (shift amount 0-7)
Output:  R[7:0] = A << shamt
```
Build as cascaded conditional shifts:
- Stage 0: shift by 0 or 1 (controlled by shamt[0])
- Stage 1: shift by 0 or 2 (controlled by shamt[1])
- Stage 2: shift by 0 or 4 (controlled by shamt[2])

**Part C:** 8-bit Right Shifter
Same structure, shifting right instead.

**Part D:** Combined Shifter
```
Inputs:  A[7:0], shamt[2:0], DIR (0=left, 1=right)
Output:  R[7:0]
```

**Deliverable:**
- `bitwise_unit.circ`
- `shifter_8bit.circ`

**Challenge (Optional):**
Why does the barrel shifter approach use O(log n) stages instead of O(n) muxes?

---

### Week 6: ALU Part 3 — Comparator and Complete ALU

**Topics:**
- Magnitude comparator
- Signed vs unsigned comparison
- Integrating all ALU components

**Lecture Content:**
- Comparison using subtraction: A - B, check sign and zero
- Zero detection: NOR all result bits
- Less-than detection: sign bit of A - B (for signed)
- Building the complete ALU with operation select
- ALU operation encoding

**Tutorial: Build Comparator and Complete ALU**

**Part A:** Zero Detector
```
Input:  R[7:0]
Output: Z (1 if R == 0, else 0)
```

**Part B:** Less-Than Comparator
```
Inputs:  A[7:0], B[7:0]
Output:  LT (1 if A < B, signed comparison)
```
Hint: Compute A - B, examine sign bit. Handle overflow case.

**Part C:** Equality Comparator
```
Inputs:  A[7:0], B[7:0]
Output:  EQ (1 if A == B)
```
Hint: XOR each bit pair, NOR the results.

**Part D:** Complete ALU
```
Inputs:  A[7:0], B[7:0], ALUop[3:0]
Outputs: R[7:0] (result)
         Flags[1:0] = {LT, EQ} (for comparison ops)

ALUop  Operation
0000   ADD:  R = A + B
0001   SUB:  R = A - B
0010   AND:  R = A & B
0011   OR:   R = A | B
0100   XOR:  R = A ^ B
0101   SHL:  R = A << B[2:0]
0110   SHR:  R = A >> B[2:0]
0111   MOV:  R = A (passthrough)
1000   LT:   Flags = (A < B)
1001   EQ:   Flags = (A == B)
```

**Deliverable:**
- `comparator.circ`
- `alu_complete.circ`

**Testing Matrix:**
Provide test vectors for all operations.

---

### Week 7: Instruction Decoder and Control Unit

**Topics:**
- Instruction format decoding
- Extracting opcode and operands
- Control signal generation

**Lecture Content:**
- Review EE8 instruction formats (R-type, I-type, J-type)
- Extracting fields using splitters
- Opcode to control signal mapping
- Multiplexer control for data paths
- Enable signals for register write

**Tutorial: Build Instruction Decoder**

**Part A:** Instruction Field Extractor
```
Input:  instruction[15:0]
Outputs:
  opcode[3:0]   = instruction[15:12]
  Rs1[1:0]      = instruction[11:10]
  Rs2[1:0]      = instruction[9:8]
  Rd[1:0]       = instruction[7:6]
  immediate[7:0] = instruction[7:0]
```

**Part B:** Control Signal Generator
```
Input:  opcode[3:0]
Outputs:
  ALUop[3:0]    - Operation for ALU
  RegWrite      - Enable register write
  ImmSel        - Select immediate (for LDI)
  Jump          - Unconditional jump
  Branch        - Conditional branch (JZ/JNZ)
  BranchCond    - Branch condition (0=JZ, 1=JNZ)
  Halt          - Stop clock
```

**Control Signal Table:**
| Opcode | Mnemonic | ALUop | RegWrite | ImmSel | Jump | Branch | BranchCond |
|--------|----------|-------|----------|--------|------|--------|------------|
| 0000 | ADD | 0000 | 1 | 0 | 0 | 0 | X |
| 0001 | SUB | 0001 | 1 | 0 | 0 | 0 | X |
| ... | ... | ... | ... | ... | ... | ... | ... |
| 1010 | LDI | XXXX | 1 | 1 | 0 | 0 | X |
| 1011 | JMP | XXXX | 0 | X | 1 | 0 | X |
| 1100 | JZ | XXXX | 0 | X | 0 | 1 | 0 |
| 1101 | JNZ | XXXX | 0 | X | 0 | 1 | 1 |
| 1110 | NOP | XXXX | 0 | X | 0 | 0 | X |
| 1111 | HALT | XXXX | 0 | X | 0 | 0 | X |

**Deliverable:**
- `instruction_decoder.circ`
- `control_unit.circ`

**Design Choice:**
Students may implement using either:
- ROM-based lookup (simpler, just a truth table)
- Combinational logic (more educational)

---

### Week 8: Program Counter and Memory

**Topics:**
- Program counter design
- ROM for instruction storage
- Address calculation for jumps

**Lecture Content:**
- Program counter: an 8-bit register that auto-increments
- Incrementer: PC + 1
- Jump logic: select between PC+1 and jump target
- Conditional jump: based on flags
- ROM as instruction memory
- Loading programs into ROM

**Tutorial: Build PC and Memory System**

**Part A:** 8-bit Incrementer
```
Input:  PC[7:0]
Output: PC_next[7:0] = PC + 1
```

**Part B:** Program Counter with Jump
```
Inputs:
  CLK
  jump_addr[7:0]
  Jump (unconditional jump)
  Branch (conditional)
  BranchCond (0=JZ, 1=JNZ)
  Flags[1:0] (from RF)
  Halt

Output: PC[7:0]

Behavior:
  If Halt: PC unchanged
  Else if Jump: PC = jump_addr
  Else if Branch AND condition met: PC = jump_addr
  Else: PC = PC + 1
```

**Part C:** Instruction ROM
```
Input:  address[7:0] (from PC)
Output: instruction[15:0]
```
Use Logisim's built-in ROM component. Load with test program.

**Deliverable:**
- `program_counter.circ`
- `instruction_memory.circ`
- Test program loaded in ROM

**Test Program for ROM:**
```
Address  Hex     Assembly
0        A00A    LDI R0 10
1        A105    LDI R1 5
2        0018    ADD R0 R1 RO
3        F000    HALT
```

---

### Week 9: Integration — Complete CPU

**Topics:**
- Datapath design
- Connecting all components
- Clock distribution
- Testing and debugging

**Lecture Content:**
- CPU datapath diagram
- Signal flow through the CPU
- Critical paths and timing considerations
- Testing methodology
- Common integration issues and debugging

**Tutorial: Build Complete CPU**

**CPU Datapath Diagram:**
```
                    ┌─────────────┐
                    │ Instruction │
          ┌────────►│     ROM     │
          │         └──────┬──────┘
          │                │ instruction[15:0]
          │                ▼
          │         ┌─────────────┐
          │         │ Instruction │
          │         │   Decoder   │
          │         └──────┬──────┘
          │                │ control signals
      ┌───┴───┐            │
      │       │            ▼
      │  PC   │◄───────────────────────┐
      │       │     ┌─────────────┐    │
      └───────┘     │  Register   │    │
                    │    File     │    │
                    │  (R0,R1,    │    │
                    │   RO,RF)    ├────┼──► 7-seg
                    └──────┬──────┘    │
                           │ A, B      │
                           ▼           │
                    ┌─────────────┐    │
                    │     ALU     │    │
                    │             ├────┘
                    └─────────────┘
                      result, flags
```

**Integration Checklist:**
1. [ ] Connect PC output to ROM address input
2. [ ] Connect ROM output to instruction decoder
3. [ ] Connect Rs1, Rs2, Rd fields to register file
4. [ ] Connect register outputs to ALU inputs A and B
5. [ ] Connect ALU output to register file write data
6. [ ] Add mux for immediate value (LDI instruction)
7. [ ] Connect control signals to all enable/select lines
8. [ ] Connect flags to RF and to branch logic
9. [ ] Connect RO to 7-segment display
10. [ ] Add clock signal and step button

**Deliverable:**
- `ee8_cpu.circ` (complete integrated CPU)

**Testing:**
Run the test programs from Week 8. Verify:
- Registers update correctly
- ALU operations produce correct results
- Jumps and branches work
- RO displays on 7-segment
- HALT stops execution

---

### Week 10: Testing, Debugging, and Extensions

**Topics:**
- Systematic testing methodology
- Debugging strategies
- Optional extensions

**Lecture Content:**
- Writing test programs
- Edge cases and corner cases
- Using step mode for debugging
- Reading timing diagrams in Logisim
- Extension ideas for advanced students

**Tutorial: Comprehensive Testing**

**Part A: Test Suite**
Write programs to test each instruction:

```
; Test ADD
LDI R0 100
LDI R1 55
ADD R0 R1 RO    ; Expected: 155
HALT

; Test SUB
LDI R0 100
LDI R1 55
SUB R0 R1 RO    ; Expected: 45
HALT

; Test SUB (negative result)
LDI R0 10
LDI R1 20
SUB R0 R1 RO    ; Expected: 246 (-10 in two's complement)
HALT

; Test LT
LDI R0 5
LDI R1 10
LT R0 R1        ; RF = 1
MOV RF RO       ; Display: 1
HALT

; Test JNZ (loop)
LDI R0 5
LDI R1 1
LDI RF 0
loop: SUB R0 R1 R0
      MOV R0 RO
      EQ R0 RF
      JZ loop       ; Continue if R0 != 0
      HALT
```

**Part B: Automated Testing**
- Provide ROM images with expected final register states
- Students run their CPU and compare results
- Score based on number of passing tests

**Part C: Optional Extensions**
For advanced students or extra credit:

1. **Additional Instructions**
   - ADDI (add immediate to register)
   - NOT (bitwise invert)
   - INC/DEC (increment/decrement by 1)

2. **Hardware Improvements**
   - Carry flag output from ALU
   - Stack pointer and PUSH/POP instructions
   - Subroutine calls (JSR/RET)

3. **Input Capability**
   - Add input switches that can be read into a register
   - Memory-mapped I/O

4. **Performance Analysis**
   - Count clock cycles for programs
   - Discuss critical path and maximum clock frequency

**Deliverable:**
- Test results document
- Final `ee8_cpu.circ` submission
- (Optional) Extension implementations

---

## Assessment Structure

### Weekly Tutorial Submissions (40%)
- Weeks 2-9: Submit Logisim circuit files
- Graded on functionality and design quality
- Each week: 5%

### Final CPU Submission (40%)
- Complete, working CPU implementation
- Graded using automated test suite
- Must pass minimum set of tests to pass

### Report (20%)
- Brief technical report (1500-2000 words)
- Document design decisions
- Discuss challenges and solutions
- Include block diagram of final design
- Reflection on learning outcomes

---

## Resources

### Logisim Tips
- Use tunnels to avoid wire clutter
- Name all tunnels clearly (e.g., `CLK`, `PC[7:0]`, `ALU_result`)
- Create subcircuits for reusable components
- Use probes for debugging
- Save frequently!

### Common Issues
| Problem | Solution |
|---------|----------|
| "Wire has multiple drivers" | Check for shorted outputs |
| Register not updating | Verify clock and enable signals |
| Wrong bits extracted | Check splitter configuration |
| Jump not working | Verify branch condition logic |

### Recommended Reading
- Computer Organization and Design (Patterson & Hennessy) — Chapter 4
- Digital Design (Mano) — Chapters on sequential circuits
- EXAPUNKS instruction reference (for assembly inspiration)

---

## Appendix: Component Checklist

Students should have these subcircuits by Week 9:

| Week | Component | File |
|------|-----------|------|
| 1 | 8-bit 2:1 Mux | `mux_2to1_8bit.circ` |
| 1 | 8-bit 4:1 Mux | `mux_4to1_8bit.circ` |
| 2 | D Latch | `d_latch.circ` |
| 2 | D Flip-Flop | `d_flipflop.circ` |
| 2 | D FF with Enable | `d_flipflop_enable.circ` |
| 3 | 8-bit Register | `register_8bit.circ` |
| 3 | Register File | `register_file.circ` |
| 4 | 8-bit Adder | `adder_8bit.circ` |
| 4 | Adder/Subtractor | `adder_subtractor_8bit.circ` |
| 5 | Bitwise Unit | `bitwise_unit.circ` |
| 5 | Shifter | `shifter_8bit.circ` |
| 6 | Comparator | `comparator.circ` |
| 6 | Complete ALU | `alu_complete.circ` |
| 7 | Instruction Decoder | `instruction_decoder.circ` |
| 7 | Control Unit | `control_unit.circ` |
| 8 | Program Counter | `program_counter.circ` |
| 8 | Instruction Memory | `instruction_memory.circ` |
| 9 | **Complete CPU** | `ee8_cpu.circ` |

---

*End of Weekly Lesson Plan*
