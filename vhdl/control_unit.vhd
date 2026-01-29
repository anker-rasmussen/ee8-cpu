-- EE8 CPU Control Unit
-- Generates control signals based on opcode

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port (
        opcode      : in  STD_LOGIC_VECTOR(3 downto 0);   -- Instruction opcode
        reg_write   : out STD_LOGIC;                       -- Enable register write
        alu_op      : out STD_LOGIC_VECTOR(3 downto 0);   -- ALU operation
        imm_sel     : out STD_LOGIC;                       -- Select immediate (for LDI)
        jump        : out STD_LOGIC;                       -- Unconditional jump
        branch      : out STD_LOGIC;                       -- Conditional branch
        branch_cond : out STD_LOGIC;                       -- 0=JZ, 1=JNZ
        halt        : out STD_LOGIC;                       -- Halt CPU
        flag_write  : out STD_LOGIC                        -- Write to RF from flags
    );
end control_unit;

architecture Behavioral of control_unit is
begin
    process(opcode)
    begin
        -- Default values
        reg_write   <= '0';
        alu_op      <= "0000";
        imm_sel     <= '0';
        jump        <= '0';
        branch      <= '0';
        branch_cond <= '0';
        halt        <= '0';
        flag_write  <= '0';

        case opcode is
            -- ALU Operations (write result to Rd)
            when "0000" =>  -- ADD
                reg_write <= '1';
                alu_op <= "0000";

            when "0001" =>  -- SUB
                reg_write <= '1';
                alu_op <= "0001";

            when "0010" =>  -- AND
                reg_write <= '1';
                alu_op <= "0010";

            when "0011" =>  -- OR
                reg_write <= '1';
                alu_op <= "0011";

            when "0100" =>  -- XOR
                reg_write <= '1';
                alu_op <= "0100";

            when "0101" =>  -- SHL
                reg_write <= '1';
                alu_op <= "0101";

            when "0110" =>  -- SHR
                reg_write <= '1';
                alu_op <= "0110";

            when "0111" =>  -- MOV
                reg_write <= '1';
                alu_op <= "0111";

            -- Comparison Operations (write to RF)
            when "1000" =>  -- LT
                reg_write <= '1';
                flag_write <= '1';
                alu_op <= "1000";

            when "1001" =>  -- EQ
                reg_write <= '1';
                flag_write <= '1';
                alu_op <= "1001";

            -- Load Immediate
            when "1010" =>  -- LDI
                reg_write <= '1';
                imm_sel <= '1';
                alu_op <= "0111";  -- MOV (passthrough)

            -- Control Flow
            when "1011" =>  -- JMP (unconditional jump)
                jump <= '1';

            when "1100" =>  -- JZ (jump if RF=0)
                branch <= '1';
                branch_cond <= '0';

            when "1101" =>  -- JNZ (jump if RF!=0)
                branch <= '1';
                branch_cond <= '1';

            -- Reserved / NOP
            when "1110" =>  -- NOP
                null;  -- Do nothing

            -- Halt
            when "1111" =>  -- HALT
                halt <= '1';

            when others =>
                null;  -- Default: NOP behavior
        end case;
    end process;

end Behavioral;
