-- EE8 CPU Testbench
-- Tests: LDI R0,10 / LDI R1,5 / ADD R0,R1,RO / HALT
-- Expected: seven_seg = 0x0F (15)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ee8_cpu_tb is
end ee8_cpu_tb;

architecture Behavioral of ee8_cpu_tb is

    -- Component under test
    component ee8_cpu is
        Port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            rom_data  : in  STD_LOGIC_VECTOR(15 downto 0);
            rom_addr  : out STD_LOGIC_VECTOR(7 downto 0);
            seven_seg : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Signals
    signal clk       : STD_LOGIC := '0';
    signal rst       : STD_LOGIC := '1';
    signal rom_data  : STD_LOGIC_VECTOR(15 downto 0);
    signal rom_addr  : STD_LOGIC_VECTOR(7 downto 0);
    signal seven_seg : STD_LOGIC_VECTOR(7 downto 0);

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

    -- ROM contents (test program)
    type rom_type is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
    signal rom : rom_type := (
        -- Address 0: LDI R0, 10  (opcode=1010, rs1=00, imm=0x0A)
        -- 1010 00xx xxxx 1010 = 0xA00A
        0 => x"A00A",
        -- Address 1: LDI R1, 5   (opcode=1010, rs1=01, imm=0x05)
        -- 1010 01xx xxxx 0101 = 0xA405
        1 => x"A405",
        -- Address 2: ADD R0, R1, RO (opcode=0000, rs1=00, rs2=01, rd=10)
        -- 0000 00 01 10 xxxxxx = 0x0180
        2 => x"0180",
        -- Address 3: HALT (opcode=1111)
        3 => x"F000",
        others => x"0000"
    );

begin

    -- Instantiate CPU
    uut: ee8_cpu
        port map (
            clk       => clk,
            rst       => rst,
            rom_data  => rom_data,
            rom_addr  => rom_addr,
            seven_seg => seven_seg
        );

    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- ROM read (directly from address, with guard for metavalues)
    rom_data <= rom(to_integer(unsigned(rom_addr))) when not is_x(rom_addr) else x"0000";

    -- Test stimulus
    stim_process: process
    begin
        -- Reset
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';

        -- Let CPU run for several cycles
        wait for CLK_PERIOD * 10;

        -- Check result
        assert seven_seg = x"0F"
            report "FAIL: Expected seven_seg=0x0F (15), got " &
                   integer'image(to_integer(unsigned(seven_seg)))
            severity error;

        if seven_seg = x"0F" then
            report "PASS: seven_seg = 0x0F (15) as expected" severity note;
        end if;

        -- End simulation
        report "Simulation complete" severity note;
        wait;
    end process;

end Behavioral;
