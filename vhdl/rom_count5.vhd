-- EE8 CPU Program ROM: Count to 5
-- Counts 0→4 in RO (R2), resets, repeats forever

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom_count5 is
    Port (
        addr : in  STD_LOGIC_VECTOR(3 downto 0);
        data : out STD_LOGIC_VECTOR(15 downto 0)
    );
end rom_count5;

architecture Behavioral of rom_count5 is
    type rom_array_t is array (0 to 15) of STD_LOGIC_VECTOR(15 downto 0);

    -- PROGRAM: Count to 5
    -- R0 = limit (5), R1 = step (1), R2/RO = counter, R3/RF = comparison
    -- Display: 00 01 02 03 04 00 01 02 03 04 ...
    constant rom_data : rom_array_t := (
        0  => x"A005",  -- LDI R0, 5       ; limit = 5
        1  => x"A401",  -- LDI R1, 1       ; step = 1
        2  => x"A800",  -- LDI R2, 0       ; counter = 0 (reset label)
        3  => x"8800",  -- LT  R2, R0      ; RF = (counter < limit)?
        4  => x"CC02",  -- JZ  RF, 2       ; if RF=0 (counter >= limit), reset
        5  => x"0680",  -- ADD R1, R2, R2  ; counter += 1
        6  => x"B003",  -- JMP 3           ; loop
        others => x"F000"  -- HALT (unused)
    );

begin
    data <= rom_data(to_integer(unsigned(addr)));
end Behavioral;
