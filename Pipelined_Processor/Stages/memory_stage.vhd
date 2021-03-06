library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity memory_stage is
    generic(
        word_width: integer := 32;
        reg_addr_width: integer := 5
    );

    port(
        clock: in std_logic;

        --input signals
        alu_result_in: in std_logic_vector (word_width-1 downto 0);
        reg_write_addr_in: in std_logic_vector (reg_addr_width-1 downto 0);
        mem_write_data_in: in std_logic_vector (word_width-1 downto 0);

        --input control signals
        reg_file_enable_in: in std_logic;
        mem_to_reg_flag_in: in std_logic;
        mem_write_request_in: in std_logic;
        mem_read_request_in: in std_logic;
        
        --output signals
        mem_write_data_out: out std_logic_vector (word_width-1 downto 0);
        mem_addr_out: out std_logic_vector (word_width-1 downto 0);
        alu_result_out: out std_logic_vector (word_width-1 downto 0);
        reg_write_addr_out: out std_logic_vector (reg_addr_width-1 downto 0);

        --output control signals
        reg_file_enable_out: out std_logic;
        mem_to_reg_flag_out: out std_logic;
        mem_write_request_out: out std_logic;
        mem_read_request_out: out std_logic;

        -- * Forwarding control * --          
        -- forwarding outputs:
        forwarding_mem_exe_reg_data : out std_logic_vector(word_width-1 downto 0);  -- MEM->EX forwarding, across one inst
        forwarding_mem_exe_reg_addr : out std_logic_vector(4 downto 0)
    );
end memory_stage;

architecture Behavior of memory_stage is

begin
    memory: process(clock)
    begin
        if rising_edge(clock) then
            -- passing control signals
            reg_file_enable_out <= reg_file_enable_in;
            mem_to_reg_flag_out <= mem_to_reg_flag_in;
            mem_write_request_out <= mem_write_request_in;
            mem_read_request_out <= mem_read_request_in;

            -- passing memory data and address 
            mem_addr_out <= alu_result_in; -- NOTE: that this may not be an address, if it isn't, control signals prevent such interpretation
            mem_write_data_out <= mem_write_data_in;    -- for STORE instruction to modify memory

            -- passing register data and address for writeback
            alu_result_out <= alu_result_in; -- similarly this may not be a result for writeback
            reg_write_addr_out <= reg_write_addr_in;

            -- handling forwarding
            forwarding_mem_exe_reg_addr <= reg_write_addr_in;
            forwarding_mem_exe_reg_data <= alu_result_in;
        end if;
    end process;

end Behavior;



