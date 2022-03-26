
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
        instruction: out std_logic_vector (bit_width-1 downto 0); --required

        m_addr: out integer range 0 to memory_size-1;
        m_read: out std_logic;
        m_readdata: in std_logic_vector (bit_width-1 downto 0);
        -- m_waitrequest: in std_logic
        -- write is not needed in fetch stage
    );
end fetchStage;

architecture arch of fetchStage is
    signal pc_register: integer range 0 to memory_size-1 := 0;
    signal pc_next_addr: integer range 0 to memory_size-1 := 0;
    signal readbuffer: std_logic_vector (bit_width-1 downto 0);

    component memory is
        generic(

            word_size : INTEGER := 32;

        );
        port(
            clock: IN STD_LOGIC;
            writedata: IN STD_LOGIC_VECTOR (word_size-1 DOWNTO 0);    -- WORD ADDRESSABILITY; However, only data memory can be written
            memwrite: IN STD_LOGIC;							-- write reqeust for data
            
            inst_address: IN INTEGER RANGE 0 TO inst_ram_size-1;
            data_address: IN INTEGER RANGE 0 TO data_ram_size-1;
        
            datamemread: IN STD_LOGIC;						-- read request for data
            instmemread: IN STD_LOGIC;						-- read request for instruction
        
            readdata: OUT STD_LOGIC_VECTOR (word_size-1 DOWNTO 0);	-- WORD ADDRESSABILITY
            waitrequest: OUT STD_LOGIC;
        
            memload: IN STD_LOGIC;			-- signal to load initial instructions from "program.txt"	
            memoutput: IN STD_LOGIC			-- signal to write output file
        );
        end component;
begin

dut: memory
port map (
    clock=>clock,
    instmemread=>m_read,
    inst_address=>m_addr,
    readdata=>readbuffer
    -- waitrequest=>m_waitrequest,
);

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
        pc_register <= pc_next_addr;
    end if;
end process;

memory_process: process(clock, reset, pc_register,m_readdata,stall)
begin
    -- TODO: get instructions from memory
    if reset = '1' or stall = '1' then
        -- do nothing
        instruction <= x"ffffffff"; -- garbage output for stall to notify decode and execute stage
    elsif rising_edge(clock) then
        m_read <= '1';
        m_addr <= pc_register;
        instruction <= readbuffer;

    end if;

end process;
end architecture;