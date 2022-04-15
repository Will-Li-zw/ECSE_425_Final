library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetch_stage is
    generic(
        inst_ram_size: integer := 4096; --instruction memory size is 4096 bytes
        bit_width: integer := 32
    );

    port(
        clock       : in std_logic; --required
        reset       : in std_logic; --required
        stall       : in std_logic; --required
        if_branch   : in std_logic := '0'; -- if branch
        if_jump     : in std_logic := '0';
        jump_addr   : in std_logic_vector (bit_width-1 downto 0):=(others=>'0'); --TODO: from decode stage
        branch_addr : in std_logic_vector (bit_width-1 downto 0):=(others=>'0'); -- TODO: from execute stage
        -- output
        pc          : out std_logic_vector (bit_width-1 downto 0) := (others => '0');  -- all initalize to 0s
        pc_next     : out std_logic_vector (bit_width-1 downto 0) := (others => '0')
        -- mem_output  : out std_logic -- control logic for judging when CPU has finished
    );
end fetch_stage;

architecture arch of fetch_stage is
    -- set to integer will make our calculation easier
    signal pc_register      : integer := 0;
    signal pc_next_register : integer := 0;
begin

    -- trigger when sensitive list is triggered
    pc_process: process(clock,reset,pc_register,pc_next_register,stall,if_branch,if_jump)
    begin
        -- updatee pc_next_register
        if (reset='1') then
            pc_next_register <= 0;
            pc_register <= 0;
        elsif (rising_edge(clock)) then
            if (if_branch='1') then
                pc_register <= to_integer( unsigned(branch_addr) );
                pc_next_register <= to_integer( unsigned(branch_addr) ) + 4;
            elsif (if_jump='1') then
                pc_register <= to_integer( unsigned(jump_addr) );
                pc_next_register <= to_integer( unsigned(jump_addr) )+4;
            elsif (pc_register+4 >= inst_ram_size-1) then   -- if pipeline goes to end of instruction mem, stop it
                -- pc_register doesn't change
                pc_next_register <= pc_register;    
            elsif (stall='1') then
                -- pc_next_register <= pc_register;   do not update pc_register NOR pc_next_register
            else
                pc_register <= pc_next_register;
                pc_next_register <= pc_next_register + 4;
            end if;
        end if;
    end process;

    -- change the output
    pc <= std_logic_vector( to_unsigned(pc_register, bit_width) );
    pc_next <= std_logic_vector( to_unsigned(pc_next_register, bit_width) );
end architecture;