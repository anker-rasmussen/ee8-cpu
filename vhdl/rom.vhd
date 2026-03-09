-- EE8 CPU Program ROM (ISA v4.0)
-- 16 x 16-bit ROM with preloaded test program
-- Students can modify the rom_data array with their own programs

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
    Port (
        addr : in  STD_LOGIC_VECTOR(3 downto 0);   -- 4-bit address from PC
        data : out STD_LOGIC_VECTOR(15 downto 0)    -- 16-bit instruction output
    );
end rom;

architecture Behavioral of rom is
    -- ROM type: 16 entries of 16-bit instructions
    type rom_array_t is array (0 to 15) of STD_LOGIC_VECTOR(15 downto 0);

    -- =========================================================================
    -- INSTRUCTION ENCODING REFERENCE (ISA v4.0):
    -- =========================================================================
    -- R-Type: [15:12]=opcode [11:10]=Rs1 [9:8]=Rs2 [7:6]=Rd [5:0]=unused
    -- I-Type: [15:12]=opcode [11:10]=unused [9:8]=Rd [7:0]=immediate
    -- J-Type: [15:12]=opcode [11:10]=Rcond [9:4]=unused [3:0]=address
    --
    -- REGISTERS: R0=00, R1=01, R2=10, R3=11
    --
    -- OPCODES:
    --   0x0=ADD  Rs1+Rs2->Rd       0x8=LT   (Rs1<Rs2)->R3
    --   0x1=SUB  Rs1-Rs2->Rd       0x9=EQ   (Rs1=Rs2)->R3
    --   0x2=AND  Rs1&Rs2->Rd       0xA=LDI  imm->Rd
    --   0x3=OR   Rs1|Rs2->Rd       0xB=JMP  PC=addr
    --   0x4=XOR  Rs1^Rs2->Rd       0xC=JZ   if Rcond=0: PC=addr
    --   0x5=SHL  Rs1<<Rs2->Rd      0xD=JNZ  if Rcond/=0: PC=addr
    --   0x6=SHR  Rs1>>Rs2->Rd      0xE=(reserved / SYS_ERR)
    --   0x7=MOV  Rs1->Rd (Rs2=00)  0xF=HALT
    --
    -- ENCODING EXAMPLES:
    --   LDI R0, 10:     1010_00_00_0000_1010 = 0xA00A
    --   LDI R1, 5:      1010_00_01_0000_0101 = 0xA105
    --   ADD R0, R1, R2: 0000_00_01_10_000000 = 0x0180
    --   MOV R0, R2:     0111_00_00_10_000000 = 0x7080
    --   LT R0, R1:      1000_00_01_xx_xxxxxx = 0x8100
    --   JNZ R3, 2:      1101_11_000000_0010  = 0xDC02
    --   HALT:           1111_0000_0000_0000  = 0xF000
    -- =========================================================================

    -- PROGRAM: Bit bounce (single bit shifts left then right)
    -- Display: 01 02 04 08 10 20 40 80 40 20 10 08 04 02 01 ...
    -- =========================================================================
    constant rom_data : rom_array_t := (
        0  => x"A001",  -- LDI R0, 0x01    ; bit = 0x01
        1  => x"A401",  -- LDI R1, 1       ; shift amount = 1
        -- SHIFT LEFT
        2  => x"7080",  -- MOV R0, _, RO   ; display
        3  => x"AC80",  -- LDI RF, 0x80    ; compare value
        4  => x"9300",  -- EQ R0, RF       ; reached top?
        5  => x"D008",  -- JNZ 8           ; yes -> shift right
        6  => x"5100",  -- SHL R0, R1, R0  ; R0 <<= 1
        7  => x"B002",  -- JMP 2           ; loop
        -- SHIFT RIGHT
        8  => x"7080",  -- MOV R0, _, RO   ; display
        9  => x"AC01",  -- LDI RF, 0x01    ; compare value
        10 => x"9300",  -- EQ R0, RF       ; reached bottom?
        11 => x"D002",  -- JNZ 2           ; yes -> shift left
        12 => x"6100",  -- SHR R0, R1, R0  ; R0 >>= 1
        13 => x"B008",  -- JMP 8           ; loop

        -- Remaining addresses filled with HALT
        others => x"F000"
    );

begin
    -- Combinational read (active on address change)
    data <= rom_data(to_integer(unsigned(addr)));
end Behavioral;
