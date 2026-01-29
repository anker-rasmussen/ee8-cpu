-- EE8 CPU Program Counter
-- 8-bit PC with jump/branch logic

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
    Port (
        clk         : in  STD_LOGIC;                      -- Clock
        rst         : in  STD_LOGIC;                      -- Reset (sets PC to 0)
        halt        : in  STD_LOGIC;                      -- Halt signal (freezes PC)
        jump        : in  STD_LOGIC;                      -- Unconditional jump
        branch      : in  STD_LOGIC;                      -- Conditional branch
        branch_cond : in  STD_LOGIC;                      -- Branch condition (0=JZ, 1=JNZ)
        flag_rf     : in  STD_LOGIC_VECTOR(7 downto 0);   -- RF register for condition check
        jump_addr   : in  STD_LOGIC_VECTOR(7 downto 0);   -- Jump target address
        pc_out      : out STD_LOGIC_VECTOR(7 downto 0)    -- Current PC value
    );
end program_counter;

architecture Behavioral of program_counter is
    signal pc_reg : unsigned(7 downto 0) := (others => '0');
    signal rf_is_zero : STD_LOGIC;
    signal branch_taken : STD_LOGIC;
begin

    -- Check if RF is zero
    rf_is_zero <= '1' when flag_rf = x"00" else '0';

    -- Determine if branch should be taken
    -- branch_cond=0: JZ (jump if zero) -> take if RF=0
    -- branch_cond=1: JNZ (jump if not zero) -> take if RF!=0
    branch_taken <= branch and ((not branch_cond and rf_is_zero) or
                                (branch_cond and not rf_is_zero));

    -- PC update logic
    process(clk, rst)
    begin
        if rst = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if halt = '1' then
                -- PC unchanged on halt
                pc_reg <= pc_reg;
            elsif jump = '1' then
                -- Unconditional jump
                pc_reg <= unsigned(jump_addr);
            elsif branch_taken = '1' then
                -- Conditional branch taken
                pc_reg <= unsigned(jump_addr);
            else
                -- Normal increment
                pc_reg <= pc_reg + 1;
            end if;
        end if;
    end process;

    pc_out <= std_logic_vector(pc_reg);

end Behavioral;
