-- EE8 CPU Program ROM
-- 256 x 16-bit ROM with preloaded test program
-- Students can modify the rom_data array with their own programs

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
    Port (
        addr : in  STD_LOGIC_VECTOR(7 downto 0);   -- 8-bit address from PC
        data : out STD_LOGIC_VECTOR(15 downto 0)   -- 16-bit instruction output
    );
end rom;

architecture Behavioral of rom is
    -- ROM type: 256 entries of 16-bit instructions
    type rom_array_t is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0);

    -- =========================================================================
    -- INSTRUCTION ENCODING REFERENCE:
    -- =========================================================================
    -- Format: [15:12]=opcode [11:10]=rs1 [9:8]=rs2 [7:6]=rd [5:0]=unused
    --         [7:0]=immediate (for LDI, JMP, JZ, JNZ)
    --
    -- REGISTERS: R0=00, R1=01, RO=10, RF=11
    --
    -- OPCODES:
    --   0x0=ADD  rs1+rs2->rd     0x8=LT   (rs1<rs2)->RF
    --   0x1=SUB  rs1-rs2->rd     0x9=EQ   (rs1=rs2)->RF
    --   0x2=AND  rs1&rs2->rd     0xA=LDI  imm->rs1
    --   0x3=OR   rs1|rs2->rd     0xB=JMP  PC=imm
    --   0x4=XOR  rs1^rs2->rd     0xC=JZ   if RF=0: PC=imm
    --   0x5=SHL  rs1<<rs2->rd    0xD=JNZ  if RF!=0: PC=imm
    --   0x6=SHR  rs1>>rs2->rd    0xE=NOP
    --   0x7=MOV  rs1->rd         0xF=HALT
    --
    -- ENCODING EXAMPLES:
    --   LDI R0, 10:     1010_00_xx_0000_1010 = 0xA00A
    --   LDI R1, 5:      1010_01_xx_0000_0101 = 0xA405
    --   ADD R0, R1, RO: 0000_00_01_10_000000 = 0x0180
    --   MOV R0, x, RO:  0111_00_xx_10_000000 = 0x7080
    --   LT R0, R1:      1000_00_01_xx_xxxxxx = 0x8100
    --   JNZ 2:          1101_xx_xx_0000_0010 = 0xD002
    --   HALT:           1111_xx_xx_xxxx_xxxx = 0xF000
    -- =========================================================================

    -- =========================================================================
    -- TEST PROGRAM: Basic arithmetic
    -- Expected result: RO = 15 (0x0F)
    -- =========================================================================
    constant rom_data : rom_array_t := (
        0  => x"A00A",  -- LDI R0, 10      ; R0 = 10
        1  => x"A405",  -- LDI R1, 5       ; R1 = 5
        2  => x"0180",  -- ADD R0, R1, RO  ; RO = R0 + R1 = 15
        3  => x"F000",  -- HALT            ; Stop execution

        -- Remaining addresses filled with NOP
        others => x"E000"
    );

begin
    -- Combinational read (active on address change)
    data <= rom_data(to_integer(unsigned(addr)));
end Behavioral;
