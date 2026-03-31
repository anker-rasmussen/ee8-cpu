-- EE8 CPU Top-Level Wrapper for Nandland Go Board (iCE40 HX1K)
-- SW1 = pause, SW2 = reset, SW3 = ROM select (hold=count-to-5), SW4 = display (hold=PC)
-- LED1 = running, LED2 = paused, LED3 = count-to-5 ROM, LED4 = showing PC

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity go_board_top is
    Port (
        i_Clk       : in  STD_LOGIC;                      -- 25 MHz oscillator

        i_Switch_1  : in  STD_LOGIC;                      -- Pause
        i_Switch_2  : in  STD_LOGIC;                      -- Reset
        i_Switch_3  : in  STD_LOGIC;                      -- ROM select (hold = count-to-5)
        i_Switch_4  : in  STD_LOGIC;                      -- Display select (hold = PC)

        o_LED_1     : out STD_LOGIC;                      -- Running indicator
        o_LED_2     : out STD_LOGIC;                      -- Pause indicator
        o_LED_3     : out STD_LOGIC;                      -- Count-to-5 ROM active
        o_LED_4     : out STD_LOGIC;                      -- Showing PC

        -- 7-Segment Display 1 (active low, high nibble)
        o_Segment1_A : out STD_LOGIC;
        o_Segment1_B : out STD_LOGIC;
        o_Segment1_C : out STD_LOGIC;
        o_Segment1_D : out STD_LOGIC;
        o_Segment1_E : out STD_LOGIC;
        o_Segment1_F : out STD_LOGIC;
        o_Segment1_G : out STD_LOGIC;

        -- 7-Segment Display 2 (active low, low nibble)
        o_Segment2_A : out STD_LOGIC;
        o_Segment2_B : out STD_LOGIC;
        o_Segment2_C : out STD_LOGIC;
        o_Segment2_D : out STD_LOGIC;
        o_Segment2_E : out STD_LOGIC;
        o_Segment2_F : out STD_LOGIC;
        o_Segment2_G : out STD_LOGIC
    );
end go_board_top;

architecture Behavioral of go_board_top is

    -- Component declarations
    component ee8_cpu is
        Port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;
            rom_data  : in  STD_LOGIC_VECTOR(15 downto 0);
            rom_addr  : out STD_LOGIC_VECTOR(7 downto 0);
            seven_seg : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component rom is
        Port (
            addr : in  STD_LOGIC_VECTOR(3 downto 0);
            data : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component rom_count5 is
        Port (
            addr : in  STD_LOGIC_VECTOR(3 downto 0);
            data : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    component hex_to_7seg is
        Port (
            hex_val  : in  STD_LOGIC_VECTOR(3 downto 0);
            segments : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    -- Button synchronizer signals (2-FF)
    signal sw1_sync : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal sw2_sync : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal sw3_sync : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal sw4_sync : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal pause    : STD_LOGIC;
    signal reset    : STD_LOGIC;
    signal rom_sel  : STD_LOGIC;  -- '1' = count-to-5 ROM
    signal disp_sel : STD_LOGIC;  -- '1' = show PC

    -- Clock divider
    signal clk_counter : unsigned(21 downto 0) := (others => '0');
    signal slow_clk    : STD_LOGIC;

    -- CPU <-> ROM signals
    signal rom_addr     : STD_LOGIC_VECTOR(7 downto 0);
    signal rom_data     : STD_LOGIC_VECTOR(15 downto 0);
    signal rom1_data    : STD_LOGIC_VECTOR(15 downto 0);  -- bit-bounce ROM
    signal rom2_data    : STD_LOGIC_VECTOR(15 downto 0);  -- count-to-5 ROM

    -- RO register data from CPU
    signal ro_data : STD_LOGIC_VECTOR(7 downto 0);

    -- Display data (muxed between RO and PC)
    signal display_data : STD_LOGIC_VECTOR(7 downto 0);

    -- 7-segment decoder outputs (active HIGH)
    signal seg1_active : STD_LOGIC_VECTOR(6 downto 0);
    signal seg2_active : STD_LOGIC_VECTOR(6 downto 0);

begin

    -- =========================================================================
    -- Button synchronizers (2-FF, synchronized to 25 MHz clock)
    -- =========================================================================
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            sw1_sync <= sw1_sync(0) & i_Switch_1;
            sw2_sync <= sw2_sync(0) & i_Switch_2;
            sw3_sync <= sw3_sync(0) & i_Switch_3;
            sw4_sync <= sw4_sync(0) & i_Switch_4;
        end if;
    end process;

    pause    <= sw1_sync(1);
    reset    <= sw2_sync(1);
    rom_sel  <= sw3_sync(1);   -- hold SW3 = count-to-5 ROM
    disp_sel <= sw4_sync(1);   -- hold SW4 = show PC

    -- =========================================================================
    -- Clock divider: 25 MHz / 2^21 ≈ 11.92 Hz, gated by pause
    -- =========================================================================
    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if pause = '0' then
                clk_counter <= clk_counter + 1;
            end if;
        end if;
    end process;

    slow_clk <= std_logic(clk_counter(21));

    -- =========================================================================
    -- ROMs (combinational read) — SW3 selects which feeds the CPU
    -- =========================================================================
    rom_default : rom
        port map (
            addr => rom_addr(3 downto 0),
            data => rom1_data
        );

    rom_count : rom_count5
        port map (
            addr => rom_addr(3 downto 0),
            data => rom2_data
        );

    rom_data <= rom2_data when rom_sel = '1' else rom1_data;

    -- =========================================================================
    -- EE8 CPU (clocked by slow_clk)
    -- =========================================================================
    cpu_inst : ee8_cpu
        port map (
            clk       => slow_clk,
            rst       => reset,
            rom_data  => rom_data,
            rom_addr  => rom_addr,
            seven_seg => ro_data
        );

    -- =========================================================================
    -- Display mux: SW4 selects between RO register and PC
    -- =========================================================================
    display_data <= rom_addr when disp_sel = '1' else ro_data;

    -- =========================================================================
    -- 7-Segment decoders
    -- =========================================================================
    seg_high : hex_to_7seg
        port map (
            hex_val  => display_data(7 downto 4),
            segments => seg1_active
        );

    seg_low : hex_to_7seg
        port map (
            hex_val  => display_data(3 downto 0),
            segments => seg2_active
        );

    -- Invert for active-low Go Board 7-segment displays
    o_Segment1_A <= not seg1_active(6);
    o_Segment1_B <= not seg1_active(5);
    o_Segment1_C <= not seg1_active(4);
    o_Segment1_D <= not seg1_active(3);
    o_Segment1_E <= not seg1_active(2);
    o_Segment1_F <= not seg1_active(1);
    o_Segment1_G <= not seg1_active(0);

    o_Segment2_A <= not seg2_active(6);
    o_Segment2_B <= not seg2_active(5);
    o_Segment2_C <= not seg2_active(4);
    o_Segment2_D <= not seg2_active(3);
    o_Segment2_E <= not seg2_active(2);
    o_Segment2_F <= not seg2_active(1);
    o_Segment2_G <= not seg2_active(0);

    -- =========================================================================
    -- LED indicators
    -- =========================================================================
    o_LED_1 <= slow_clk;       -- Running indicator
    o_LED_2 <= pause;          -- Pause indicator
    o_LED_3 <= rom_sel;        -- Count-to-5 ROM active
    o_LED_4 <= disp_sel;       -- Showing PC

end Behavioral;
