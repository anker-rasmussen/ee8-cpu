# EE8 CPU Project Scenario: Smart Traffic Light Controller

## Background

Transport for London (TfL) is upgrading traffic signal infrastructure across outer London boroughs. The current traffic lights at many smaller junctions use fixed timing circuits that cannot be easily adjusted without hardware modifications. TfL has commissioned the development of a **programmable traffic light controller** that allows traffic engineers to modify signal timing through software rather than rewiring.

Your team has been contracted to design and prototype a simple programmable controller using the **EE8 CPU architecture**. The prototype will demonstrate that a custom-designed processor can reliably manage traffic signal sequencing, with the flexibility to adjust timing for different junctions and traffic conditions.

---

## Project Brief

### Client Requirements

TfL requires a programmable controller that can:

1. **Cycle through traffic light states** in the correct sequence:
   - Green → Amber → Red → Green (repeat)

2. **Display countdown timer** on a 7-segment display showing seconds remaining in current phase

3. **Support configurable timing** — different junctions need different phase durations:
   - A-roads: longer green phases
   - Side streets: shorter green phases
   - Near schools: extended pedestrian crossing times

4. **Operate reliably** with simple, verifiable logic

5. **Be cost-effective** for deployment across 500+ junctions

### Why a Custom CPU?

TfL evaluated several options:

| Option | Pros | Cons |
|--------|------|------|
| Commercial microcontroller | Off-the-shelf, well documented | Overkill for simple task, higher unit cost at scale, supply chain concerns |
| Fixed logic (discrete ICs) | Simple, reliable | Cannot reprogram timing without hardware changes |
| **Custom programmable CPU** | Flexible, simple, low cost at scale, full control | Requires development effort |

The custom CPU approach was selected because:
- **Simplicity**: A minimal instruction set reduces potential failure points
- **Flexibility**: Traffic engineers can update timing by changing ROM contents
- **Cost**: At 500+ units, custom silicon is more economical than commercial MCUs
- **Longevity**: No dependency on third-party chip availability

---

## Technical Specification

### Traffic Light Sequence

A standard UK junction operates with the following sequence:

```
┌─────────────────────────────────────────────────────────┐
│  State    │ North/South │ East/West │ Duration (typical)│
├───────────┼─────────────┼───────────┼───────────────────┤
│  STATE 0  │   GREEN     │   RED     │   30 seconds      │
│  STATE 1  │   AMBER     │   RED     │    3 seconds      │
│  STATE 2  │   RED       │  RED+AMBER│    2 seconds      │
│  STATE 3  │   RED       │   GREEN   │   30 seconds      │
│  STATE 4  │   RED       │   AMBER   │    3 seconds      │
│  STATE 5  │  RED+AMBER  │   RED     │    2 seconds      │
│  (repeat) │             │           │                   │
└─────────────────────────────────────────────────────────┘
```

**Note:** UK traffic lights include a "Red + Amber" phase before green to alert drivers to prepare.

### Inputs and Outputs

**Outputs (directly from CPU):**
- 7-segment display: Shows countdown timer (seconds remaining in current phase)
- Light control signals: Could be memory-mapped or directly from register bits

**Inputs (optional extension):**
- Pedestrian button: Request crossing phase (pelican/puffin crossing)
- Vehicle sensor: Detect waiting vehicles (for MOVA-style adaptive timing)

### Timing

The CPU clock will be divided down to produce a **1 Hz tick** (one count per second). The countdown timer decrements on each tick.

---

## Example Program

The following EE8 assembly program implements a simplified traffic light cycle:

```
; Traffic Light Controller for TfL
; Displays countdown on 7-seg (RO)
; Simplified 4-state cycle for demonstration

; Configuration (modify for different junctions)
; GREEN_TIME = 30 seconds
; AMBER_TIME = 3 seconds

start:
        ; === STATE 0: North/South GREEN ===
        LDI R0 30           ; Green duration = 30 seconds
        LDI R1 1            ; Decrement value
state0:
        MOV R0 RO           ; Display countdown
        LDI RF 0            ; Clear RF for comparison
        EQ R0 RF            ; Is countdown zero?
        JNZ next1           ; If zero, go to next state
        SUB R0 R1 R0        ; Decrement countdown
        ; (wait for 1 second tick - handled by clock divider)
        JMP state0          ; Continue countdown

next1:
        ; === STATE 1: North/South AMBER ===
        LDI R0 3            ; Amber duration = 3 seconds
state1:
        MOV R0 RO           ; Display countdown
        LDI RF 0
        EQ R0 RF
        JNZ next2
        SUB R0 R1 R0
        JMP state1

next2:
        ; === STATE 2: East/West GREEN ===
        LDI R0 30           ; Green duration = 30 seconds
state2:
        MOV R0 RO           ; Display countdown
        LDI RF 0
        EQ R0 RF
        JNZ next3
        SUB R0 R1 R0
        JMP state2

next3:
        ; === STATE 3: East/West AMBER ===
        LDI R0 3            ; Amber duration = 3 seconds
state3:
        MOV R0 RO           ; Display countdown
        LDI RF 0
        EQ R0 RF
        JNZ start           ; Loop back to beginning
        SUB R0 R1 R0
        JMP state3
```

### Instructions Used

| Instruction | Purpose in this program |
|-------------|------------------------|
| LDI | Load timing constants, clear RF for comparison |
| MOV | Copy countdown value to display (RO) |
| SUB | Decrement countdown timer |
| EQ | Check if countdown reached zero |
| JNZ | Branch when countdown complete |
| JMP | Loop back within state, return to start |

---

## Deliverables

### Hardware (Logisim)

1. **Complete EE8 CPU** implementing all 16 instructions
2. **7-segment display** connected to RO register
3. **ROM** programmed with traffic light controller code
4. **Clock divider** (optional) to demonstrate real-time operation

### Software

1. **Traffic light program** (as shown above, or improved version)
2. **Test programs** demonstrating all CPU instructions function correctly

### Documentation

1. Block diagram of CPU architecture
2. Brief explanation of design decisions
3. Test results showing correct operation

---

## Assessment Notes

While the traffic light scenario uses a subset of the EE8 instruction set, your CPU implementation will be tested against a **comprehensive test suite** that verifies all 16 instructions operate correctly. The scenario provides real-world context; the test suite ensures complete functionality.

### Instructions exercised by traffic light program:
- LDI, MOV, SUB, EQ, JNZ, JMP

### Additional instructions verified by test suite:
- ADD, AND, OR, XOR, SHL, SHR, LT, JZ, NOP, HALT

---

## Extension Opportunities

For students seeking additional challenge:

### Extension 1: Pelican Crossing
Add a pedestrian button input that interrupts the normal cycle to provide a crossing phase with audible signal timing.

### Extension 2: MOVA-Style Adaptive Timing
Implement Microprocessor Optimised Vehicle Actuation — use a vehicle sensor input to extend green phases when traffic is detected.

### Extension 3: Multiple Displays
Add a second 7-segment display to show the current state number alongside the countdown.

### Extension 4: Night Mode
Implement flashing amber mode for late-night operation at quieter junctions.

---

## Real-World Context

This project mirrors real traffic control systems used across the UK:

- **SCOOT (Split Cycle Offset Optimisation Technique)** — Used by TfL across London, relies on programmable controllers at each junction coordinated centrally
- **MOVA (Microprocessor Optimised Vehicle Actuation)** — Standalone adaptive controllers used at isolated UK junctions
- **UK Traffic Signs Regulations** — Specifies exact light sequences including the distinctive Red+Amber "prepare to go" phase

Simple embedded processors are preferred in safety-critical infrastructure for their predictability and verifiability. This project demonstrates the core principles behind systems that manage traffic flow for millions of Londoners daily.

---

*End of Scenario Document*
