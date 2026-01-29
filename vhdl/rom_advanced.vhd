-- EE8 CPU Program ROM - Advanced Test
-- Tests arithmetic, comparisons, and branching
-- Expected result: RO counts 1,2,3,4,5 then shows 42 (0x2A)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom_advanced is
    Port (
        addr : in  STD_LOGIC_VECTOR(7 downto 0);   -- 8-bit address from PC
        data : out STD_LOGIC_VECTOR(15 downto 0)   -- 16-bit instruction output
    );
end rom_advanced;

architecture Behavioral of rom_advanced is
    type rom_array_t is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0);

    -- =========================================================================
    -- ADVANCED TEST: Loop counter with conditional branch
    --
    -- Algorithm:
    --   R0 = 0 (counter)
    --   R1 = 1 (increment)
    --   loop:
    --     R0 = R0 + R1        ; increment counter
    --     RO = R0             ; display counter
    --     RF = (R0 < 5)       ; compare: RF=1 if R0<5, else RF=0
    --     if RF != 0: goto loop
    --   RO = 42               ; display final answer
    --   HALT
    --
    -- Encoding reference (see rom.vhd for full table):
    --   LDI Rx, imm: 1010_rx_xx_imm8
    --   ADD rs1,rs2,rd: 0000_rs1_rs2_rd_000000
    --   MOV rs1,rd: 0111_rs1_xx_rd_000000
    --   LT rs1,rs2: 1000_rs1_rs2_xx_xxxxxx (result->RF)
    --   JNZ addr: 1101_xx_xx_addr8
    -- =========================================================================

    constant rom_data : rom_array_t := (
        -- Initialize registers
        0  => x"A000",  -- LDI R0, 0       ; R0 = 0 (counter)
        1  => x"A401",  -- LDI R1, 1       ; R1 = 1 (increment)

        -- Loop start (address 2)
        2  => x"0100",  -- ADD R0, R1, R0  ; R0 = R0 + 1
        3  => x"7080",  -- MOV R0, x, RO   ; RO = R0 (display count)
        4  => x"A405",  -- LDI R1, 5       ; R1 = 5 (comparison limit)
        5  => x"8100",  -- LT R0, R1       ; RF = (R0 < 5) ? 1 : 0
        6  => x"A401",  -- LDI R1, 1       ; R1 = 1 (restore increment)
        7  => x"D002",  -- JNZ 2           ; if RF != 0, loop to addr 2

        -- Loop complete - display final answer
        8  => x"A02A",  -- LDI R0, 42      ; R0 = 42 (0x2A)
        9  => x"7080",  -- MOV R0, x, RO   ; RO = 42 (display)
        10 => x"F000",  -- HALT            ; Stop execution

        -- Fill rest with NOP
        others => x"E000"
    );

begin
    data <= rom_data(to_integer(unsigned(addr)));
end Behavioral;
