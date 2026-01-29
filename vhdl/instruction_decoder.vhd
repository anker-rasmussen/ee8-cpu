-- EE8 CPU Instruction Decoder
-- Extracts fields from 16-bit instruction word

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_decoder is
    Port (
        instruction : in  STD_LOGIC_VECTOR(15 downto 0);  -- Full instruction word
        opcode      : out STD_LOGIC_VECTOR(3 downto 0);   -- Bits [15:12]
        rs1         : out STD_LOGIC_VECTOR(1 downto 0);   -- Bits [11:10]
        rs2         : out STD_LOGIC_VECTOR(1 downto 0);   -- Bits [9:8]
        rd          : out STD_LOGIC_VECTOR(1 downto 0);   -- Bits [7:6]
        immediate   : out STD_LOGIC_VECTOR(7 downto 0)    -- Bits [7:0]
    );
end instruction_decoder;

architecture Behavioral of instruction_decoder is
begin
    -- Pure combinational field extraction
    opcode    <= instruction(15 downto 12);
    rs1       <= instruction(11 downto 10);
    rs2       <= instruction(9 downto 8);
    rd        <= instruction(7 downto 6);
    immediate <= instruction(7 downto 0);
end Behavioral;
