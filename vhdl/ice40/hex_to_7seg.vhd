-- Hex digit to 7-segment decoder
-- Input: 4-bit hex value
-- Output: 7-bit segment pattern (active HIGH)
-- Segment order: segments(6 downto 0) = A B C D E F G

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hex_to_7seg is
    Port (
        hex_val  : in  STD_LOGIC_VECTOR(3 downto 0);
        segments : out STD_LOGIC_VECTOR(6 downto 0)  -- A(6) B(5) C(4) D(3) E(2) F(1) G(0)
    );
end hex_to_7seg;

architecture Behavioral of hex_to_7seg is
begin
    process(hex_val)
    begin
        case hex_val is
            --                     ABCDEFG
            when "0000" => segments <= "1111110";  -- 0
            when "0001" => segments <= "0110000";  -- 1
            when "0010" => segments <= "1101101";  -- 2
            when "0011" => segments <= "1111001";  -- 3
            when "0100" => segments <= "0110011";  -- 4
            when "0101" => segments <= "1011011";  -- 5
            when "0110" => segments <= "1011111";  -- 6
            when "0111" => segments <= "1110000";  -- 7
            when "1000" => segments <= "1111111";  -- 8
            when "1001" => segments <= "1111011";  -- 9
            when "1010" => segments <= "1110111";  -- A
            when "1011" => segments <= "0011111";  -- b
            when "1100" => segments <= "1001110";  -- C
            when "1101" => segments <= "0111101";  -- d
            when "1110" => segments <= "1001111";  -- E
            when "1111" => segments <= "1000111";  -- F
            when others => segments <= "0000000";
        end case;
    end process;
end Behavioral;
