-- EE8 CPU Program ROM - Advanced Test (ISA v4.0)
-- Tests arithmetic, comparisons, and branching
-- Expected result: R2 counts 1,2,3,4,5 then shows 42 (0x2A)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom_advanced is
    Port (
        addr : in  STD_LOGIC_VECTOR(3 downto 0);   -- 4-bit address from PC
        data : out STD_LOGIC_VECTOR(15 downto 0)    -- 16-bit instruction output
    );
end rom_advanced;

architecture Behavioral of rom_advanced is
    type rom_array_t is array (0 to 15) of STD_LOGIC_VECTOR(15 downto 0);

    -- =========================================================================
    -- ADVANCED TEST: Loop counter with conditional branch
    --
    -- Algorithm:
    --   R0 = 0 (counter)
    --   R1 = 1 (increment)
    --   loop:
    --     R0 = R0 + R1        ; increment counter
    --     R2 = R0             ; display counter
    --     LDI R1, 5           ; load comparison limit
    --     LT R0, R1           ; R3 = (R0 < 5) ? 1 : 0
    --     LDI R1, 1           ; restore increment
    --     if R3 != 0: goto loop (Rcond=R3)
    --   R0 = 42
    --   R2 = R0              ; display final answer
    --   HALT
    --
    -- Encoding reference (ISA v4.0):
    --   LDI Rd, imm:  1010_00_Rd_imm8
    --   ADD Rs1,Rs2,Rd: 0000_Rs1_Rs2_Rd_000000
    --   MOV Rs1,Rd:   0111_Rs1_00_Rd_000000
    --   LT Rs1,Rs2:   1000_Rs1_Rs2_xx_xxxxxx (result->R3)
    --   JNZ Rcond,addr: 1101_Rcond_000000_addr4
    -- =========================================================================

    constant rom_data : rom_array_t := (
        -- Initialize registers
        0  => x"A000",  -- LDI R0, 0       ; R0 = 0 (counter)
        1  => x"A101",  -- LDI R1, 1       ; R1 = 1 (increment)

        -- Loop start (address 2)
        2  => x"0100",  -- ADD R0, R1, R0  ; R0 = R0 + 1
        3  => x"7080",  -- MOV R0, R2      ; R2 = R0 (display count)
        4  => x"A105",  -- LDI R1, 5       ; R1 = 5 (comparison limit)
        5  => x"8100",  -- LT R0, R1       ; R3 = (R0 < 5) ? 1 : 0
        6  => x"A101",  -- LDI R1, 1       ; R1 = 1 (restore increment)
        7  => x"DC02",  -- JNZ R3, 2       ; if R3 != 0, loop to addr 2

        -- Loop complete - display final answer
        8  => x"A02A",  -- LDI R0, 42      ; R0 = 42 (0x2A)
        9  => x"7080",  -- MOV R0, R2      ; R2 = 42 (display)
        10 => x"F000",  -- HALT            ; Stop execution

        -- Fill rest with HALT
        others => x"F000"
    );

begin
    data <= rom_data(to_integer(unsigned(addr)));
end Behavioral;
