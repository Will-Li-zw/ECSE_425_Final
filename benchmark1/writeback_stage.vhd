library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library WORK;

entity writeback_stage is
    generic(
        word_width: integer := 32;
        reg_address_width: integer := 5
    );

    port(
        clock: in std_logic;

        -- input signals
        read_data: in std_logic_vector (word_width-1 downto 0);
        alu_result: in std_logic_vector (word_width-1 downto 0);
        reg_address_in: in std_logic_vector (reg_address_width-1 downto 0);

        -- input control signals
        mem_to_reg_flag: in std_logic;
        reg_file_enable_in: in std_logic;

        -- output signals
        reg_file_enable_out: out std_logic;
        reg_address_out: out std_logic_vector (reg_address_width-1 downto 0);
        write_data: out std_logic_vector (word_width-1 downto 0)
    );
end writeback_stage;

architecture Behavior of writeback_stage is

    signal MUX_output: std_logic_vector(word_width-1 downto 0);

    component TWOMUX is
        PORT(
		sel : in std_logic;
		input0 : in std_logic_vector (word_width-1 downto 0);
		input1 : in std_logic_vector (word_width-1 downto 0);
		output : out std_logic_vector (word_width-1 downto 0)
       );
    end component;

begin
    MUX: TWOMUX port map(
        sel => mem_to_reg_flag,
        input0 => alu_result,
        input1 => read_data,
        output => MUX_output
    );

    writeback: process(clock, mem_to_reg_flag)
    begin
        if rising_edge(clock) then
            -- if mem_to_reg_flag='1' then
            --     write_data<=read_data;
            -- else
            --     write_data<=alu_result;
            -- end if;
            -- passing control signal 
            reg_file_enable_out <= reg_file_enable_in;
            -- passing data and reg address for update in decode
            reg_address_out <= reg_address_in;
            write_data<=MUX_output;
        end if;
    end process;

end Behavior;




