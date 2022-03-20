
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetchStage is
    generic(
        memory_size: integer := 8192; --data memory size is 8192 lines
        bit_width: integer := 32
    );

    port(
        clock: in std_logic; --required
        reset: in std_logic; --required
        stall: in std_logic; --required
        pc: out integer; --required
        instruction: out std_logic; --required

        m_addr: out integer range 0 to memory_size-1;
        m_read: out std_logic;
        m_readdata: in std_logic_vector (bit_width-1 downto 0);
        m_waitrequest: in std_logic
        -- write is not needed in fetch stage
    );
end fetchStage;

architecture arch of fetchStage is
    signal pc_register: integer range 0 to memory_size-1 := 0;
    signal pc_next_addr: integer range 0 to memory_size-1 := 0;
begin


-- trigger when sensitive list is triggered
pc_process: process(clock,reset,pc_register,pc_next_addr,stall)
begin
    pc <= pc_register;
    -- updatee pc_next_addr
    if (reset='1') then
        pc_next_addr <= 0;
    elsif (pc_register + 4 >= memory_size-1) then --exceed a word
        pc_next_addr <= pc_register;
    elsif (stall='1') then
        pc_next_addr <= pc_register;
    else
        pc_next_addr <= pc_register + 4;
    end if;

    -- update pc_register
    -- if want to reset
    if (reset='1') then
        pc_register <=0;
    elsif (rising_edge(clock)) then
        if (stall = '1') then
            -- do nothing
        else
            pc_register <= pc_next_addr;
        end if;
    end if;
end process;

stall_process: process(clock,stall)
begin
    if stall = '1' then
        -- do nothing
    end if;
end process;

memory_process: process(clock, reset, pc_register,m_readdata,m_waitrequest)
begin
    -- TODO: get instructions from memory
    -- if reset = '1' then

end process;
end architecture;