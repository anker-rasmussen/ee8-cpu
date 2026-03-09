-- EE8 CPU Arithmetic Logic Unit
-- Performs all arithmetic and logical operations

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port (
        a       : in  STD_LOGIC_VECTOR(7 downto 0);  -- Operand A (Rs1)
        b       : in  STD_LOGIC_VECTOR(7 downto 0);  -- Operand B (Rs2)
        alu_op  : in  STD_LOGIC_VECTOR(3 downto 0);  -- Operation select
        result  : out STD_LOGIC_VECTOR(7 downto 0);  -- ALU result
        flag_eq : out STD_LOGIC;                      -- Equality flag
        flag_lt : out STD_LOGIC                       -- Less-than flag
    );
end alu;

architecture Behavioral of alu is
    signal shift_amount : integer range 0 to 7 := 0;
begin
    -- Extract shift amount from lower 3 bits of b
    shift_amount <= to_integer(unsigned(b(2 downto 0)));

    process(a, b, alu_op, shift_amount)
        variable a_unsigned : unsigned(7 downto 0);
        variable b_unsigned : unsigned(7 downto 0);
    begin
        a_unsigned := unsigned(a);
        b_unsigned := unsigned(b);

        -- Default outputs
        result <= (others => '0');
        flag_eq <= '0';
        flag_lt <= '0';

        case alu_op is
            when "0000" =>  -- ADD
                result <= std_logic_vector(a_unsigned + b_unsigned);

            when "0001" =>  -- SUB
                result <= std_logic_vector(a_unsigned - b_unsigned);

            when "0010" =>  -- AND
                result <= a and b;

            when "0011" =>  -- OR
                result <= a or b;

            when "0100" =>  -- XOR
                result <= a xor b;

            when "0101" =>  -- SHL (shift left)
                result <= std_logic_vector(shift_left(a_unsigned, shift_amount));

            when "0110" =>  -- SHR (shift right)
                result <= std_logic_vector(shift_right(a_unsigned, shift_amount));

            when "0111" =>  -- MOV (passthrough A)
                result <= a;

            when "1000" =>  -- LT (less than comparison)
                if a_unsigned < b_unsigned then
                    flag_lt <= '1';
                    result <= x"01";
                else
                    flag_lt <= '0';
                    result <= x"00";
                end if;

            when "1001" =>  -- EQ (equality comparison)
                if a_unsigned = b_unsigned then
                    flag_eq <= '1';
                    result <= x"01";
                else
                    flag_eq <= '0';
                    result <= x"00";
                end if;

            when others =>
                result <= (others => '0');
        end case;
    end process;

end Behavioral;
