-- EE8 CPU Register File
-- 4 x 8-bit registers: R0, R1, RO, RF

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    Port (
        clk     : in  STD_LOGIC;                      -- Clock
        rst     : in  STD_LOGIC;                      -- Async reset
        we      : in  STD_LOGIC;                      -- Write enable
        sel_rs1 : in  STD_LOGIC_VECTOR(1 downto 0);   -- Source register 1 select
        sel_rs2 : in  STD_LOGIC_VECTOR(1 downto 0);   -- Source register 2 select
        sel_rd  : in  STD_LOGIC_VECTOR(1 downto 0);   -- Destination register select
        data_in : in  STD_LOGIC_VECTOR(7 downto 0);   -- Write data
        rs1_out : out STD_LOGIC_VECTOR(7 downto 0);   -- Source 1 data
        rs2_out : out STD_LOGIC_VECTOR(7 downto 0);   -- Source 2 data
        ro_out  : out STD_LOGIC_VECTOR(7 downto 0);   -- RO register (for 7-seg)
        rf_out  : out STD_LOGIC_VECTOR(7 downto 0)    -- RF register (for branch cond)
    );
end register_file;

architecture Behavioral of register_file is
    -- Register array: R0(00), R1(01), RO(10), RF(11)
    type reg_array_t is array (0 to 3) of STD_LOGIC_VECTOR(7 downto 0);
    signal registers : reg_array_t := (others => (others => '0'));
begin

    -- Synchronous write with async reset
    process(clk, rst)
    begin
        if rst = '1' then
            registers(0) <= (others => '0');  -- R0
            registers(1) <= (others => '0');  -- R1
            registers(2) <= (others => '0');  -- RO
            registers(3) <= (others => '0');  -- RF
        elsif rising_edge(clk) then
            if we = '1' then
                registers(to_integer(unsigned(sel_rd))) <= data_in;
            end if;
        end if;
    end process;

    -- Asynchronous read (combinational)
    rs1_out <= registers(to_integer(unsigned(sel_rs1)));
    rs2_out <= registers(to_integer(unsigned(sel_rs2)));

    -- RO always output for 7-segment display
    ro_out <= registers(2);

    -- RF always output for branch conditions
    rf_out <= registers(3);

end Behavioral;
