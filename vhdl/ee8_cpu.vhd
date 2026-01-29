-- EE8 CPU Top Level
-- Integrates all components for Logisim Evolution

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ee8_cpu is
    Port (
        clk       : in  STD_LOGIC;                      -- System clock
        rst       : in  STD_LOGIC;                      -- Reset
        rom_data  : in  STD_LOGIC_VECTOR(15 downto 0);  -- Instruction from ROM
        rom_addr  : out STD_LOGIC_VECTOR(7 downto 0);   -- Address to ROM (PC)
        seven_seg : out STD_LOGIC_VECTOR(7 downto 0)    -- 7-segment output (RO)
    );
end ee8_cpu;

architecture Structural of ee8_cpu is

    -- Component declarations
    component alu is
        Port (
            a       : in  STD_LOGIC_VECTOR(7 downto 0);
            b       : in  STD_LOGIC_VECTOR(7 downto 0);
            alu_op  : in  STD_LOGIC_VECTOR(3 downto 0);
            result  : out STD_LOGIC_VECTOR(7 downto 0);
            flag_eq : out STD_LOGIC;
            flag_lt : out STD_LOGIC
        );
    end component;

    component register_file is
        Port (
            clk     : in  STD_LOGIC;
            rst     : in  STD_LOGIC;
            we      : in  STD_LOGIC;
            sel_rs1 : in  STD_LOGIC_VECTOR(1 downto 0);
            sel_rs2 : in  STD_LOGIC_VECTOR(1 downto 0);
            sel_rd  : in  STD_LOGIC_VECTOR(1 downto 0);
            data_in : in  STD_LOGIC_VECTOR(7 downto 0);
            rs1_out : out STD_LOGIC_VECTOR(7 downto 0);
            rs2_out : out STD_LOGIC_VECTOR(7 downto 0);
            ro_out  : out STD_LOGIC_VECTOR(7 downto 0);
            rf_out  : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component instruction_decoder is
        Port (
            instruction : in  STD_LOGIC_VECTOR(15 downto 0);
            opcode      : out STD_LOGIC_VECTOR(3 downto 0);
            rs1         : out STD_LOGIC_VECTOR(1 downto 0);
            rs2         : out STD_LOGIC_VECTOR(1 downto 0);
            rd          : out STD_LOGIC_VECTOR(1 downto 0);
            immediate   : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component program_counter is
        Port (
            clk         : in  STD_LOGIC;
            rst         : in  STD_LOGIC;
            halt        : in  STD_LOGIC;
            jump        : in  STD_LOGIC;
            branch      : in  STD_LOGIC;
            branch_cond : in  STD_LOGIC;
            flag_rf     : in  STD_LOGIC_VECTOR(7 downto 0);
            jump_addr   : in  STD_LOGIC_VECTOR(7 downto 0);
            pc_out      : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component control_unit is
        Port (
            opcode      : in  STD_LOGIC_VECTOR(3 downto 0);
            reg_write   : out STD_LOGIC;
            alu_op      : out STD_LOGIC_VECTOR(3 downto 0);
            imm_sel     : out STD_LOGIC;
            jump        : out STD_LOGIC;
            branch      : out STD_LOGIC;
            branch_cond : out STD_LOGIC;
            halt        : out STD_LOGIC;
            flag_write  : out STD_LOGIC
        );
    end component;

    -- Internal signals: Instruction decoder outputs
    signal opcode    : STD_LOGIC_VECTOR(3 downto 0);
    signal rs1_sel   : STD_LOGIC_VECTOR(1 downto 0);
    signal rs2_sel   : STD_LOGIC_VECTOR(1 downto 0);
    signal rd_sel    : STD_LOGIC_VECTOR(1 downto 0);
    signal immediate : STD_LOGIC_VECTOR(7 downto 0);

    -- Internal signals: Control unit outputs
    signal reg_write   : STD_LOGIC;
    signal alu_op      : STD_LOGIC_VECTOR(3 downto 0);
    signal imm_sel     : STD_LOGIC;
    signal jump        : STD_LOGIC;
    signal branch      : STD_LOGIC;
    signal branch_cond : STD_LOGIC;
    signal halt        : STD_LOGIC;
    signal flag_write  : STD_LOGIC;

    -- Internal signals: Register file outputs
    signal rs1_data : STD_LOGIC_VECTOR(7 downto 0);
    signal rs2_data : STD_LOGIC_VECTOR(7 downto 0);
    signal rf_data  : STD_LOGIC_VECTOR(7 downto 0);  -- RF register for branch conditions

    -- Internal signals: ALU
    signal alu_a      : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_result : STD_LOGIC_VECTOR(7 downto 0);
    signal flag_eq    : STD_LOGIC;
    signal flag_lt    : STD_LOGIC;

    -- Internal signals: Register write data and destination
    signal reg_data_in : STD_LOGIC_VECTOR(7 downto 0);
    signal reg_rd_sel  : STD_LOGIC_VECTOR(1 downto 0);

    -- Internal signals: Program counter
    signal pc_value : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- Instruction Decoder
    inst_decoder: instruction_decoder
        port map (
            instruction => rom_data,
            opcode      => opcode,
            rs1         => rs1_sel,
            rs2         => rs2_sel,
            rd          => rd_sel,
            immediate   => immediate
        );

    -- Control Unit
    ctrl_unit: control_unit
        port map (
            opcode      => opcode,
            reg_write   => reg_write,
            alu_op      => alu_op,
            imm_sel     => imm_sel,
            jump        => jump,
            branch      => branch,
            branch_cond => branch_cond,
            halt        => halt,
            flag_write  => flag_write
        );

    -- ALU input selection
    -- For LDI: pass immediate through ALU (via MOV operation)
    alu_a <= immediate when imm_sel = '1' else rs1_data;

    -- ALU
    alu_inst: alu
        port map (
            a       => alu_a,
            b       => rs2_data,
            alu_op  => alu_op,
            result  => alu_result,
            flag_eq => flag_eq,
            flag_lt => flag_lt
        );

    -- Register destination selection
    -- For LDI: destination comes from rs1 field (instruction[11:10])
    -- For flag ops (LT/EQ): destination is RF (11)
    -- Otherwise: destination is rd field
    reg_rd_sel <= "11" when flag_write = '1' else
                  rs1_sel when imm_sel = '1' else
                  rd_sel;

    -- Register write data is always ALU result
    reg_data_in <= alu_result;

    -- Register File
    reg_file: register_file
        port map (
            clk     => clk,
            rst     => rst,
            we      => reg_write,
            sel_rs1 => rs1_sel,
            sel_rs2 => rs2_sel,
            sel_rd  => reg_rd_sel,
            data_in => reg_data_in,
            rs1_out => rs1_data,
            rs2_out => rs2_data,
            ro_out  => seven_seg,
            rf_out  => rf_data
        );

    -- Program Counter
    pc_inst: program_counter
        port map (
            clk         => clk,
            rst         => rst,
            halt        => halt,
            jump        => jump,
            branch      => branch,
            branch_cond => branch_cond,
            flag_rf     => rf_data,
            jump_addr   => immediate,
            pc_out      => pc_value
        );

    -- ROM address is PC
    rom_addr <= pc_value;

end Structural;
