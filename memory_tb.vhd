--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;			 -- package for io to write std_logic_vector

entity memory_tb is
end memory_tb;

architecture behavior of memory_tb is

component memory is
generic(
    inst_ram_size : INTEGER := 1024;			-- WORD ADDRESSABILITY; at most 1024 instructions
    data_ram_size : INTEGER := 8192;			-- WORD ADDRESSABILITY; 8192 words data
    word_size : INTEGER := 32;
    mem_delay : time := 0.1 ns;			-- to make life easier, mem_dealy is 0.1 CC
    clock_period : time := 1 ns;

    -- path definition
    dataoutput_filepath: string := "memory.txt";		-- TODO: is the output memory only for data?
    instruction_filepath : string := "program.txt"
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
	
-- test signals 
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal s_addr : std_logic_vector (31 downto 0);
signal s_read : std_logic := '0';
signal s_readdata : std_logic_vector (31 downto 0);
signal s_write : std_logic := '0';
signal s_writedata : std_logic_vector (31 downto 0);
signal s_waitrequest : std_logic;

signal i_addr : integer range 0 to 1023;      
signal d_addr : integer range 0 to 8191;        

signal i_read : std_logic;
signal d_read : std_logic;

signal m_readdata : std_logic_vector (31 downto 0);
signal m_write : std_logic;
signal m_writedata : std_logic_vector (31 downto 0);
signal m_waitrequest : std_logic; 

signal m_load : std_logic := '0';
signal m_output : std_logic := '0';

begin

-- Connect the components which we instantiated above to their
-- respective signals.

dut : memory
port map (
    clock => clk,
    writedata => m_writedata,
    memwrite => m_write,
    
    inst_address => i_addr,
    data_address => d_addr,

    datamemread => i_read,
    instmemread => d_read,

    readdata => m_readdata,
    waitrequest => m_waitrequest,

    memload => m_load,
    memoutput => m_output
);
				
-- clock loop
clk_process : process  
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

-- test process
test_process : process
begin
	-- Test read miss, replace from memory
	wait for clk_period;
	-- s_addr <= x"00000004";               -- read from index 1   0000 0000 0000 0000 0000 0000 0000 0100
	-- s_read <= '1';
	-- wait until rising_edge(s_waitrequest);
	-- assert s_readdata = x"00060504" report "write unsuccessful" severity error;
	-- s_read <= '0';
	
	-- wait for clk_period;
	
	-- -- Test write hit, replace from memory
	-- s_addr <= x"00000008";               -- read from index 1   0000 0000 0000 0000 0000 0000 0000 1000
	-- s_write <= '1';
	-- s_writedata <= x"11111111";			-- 4 Bytes write
	-- wait until rising_edge(s_waitrequest);
	-- assert s_readdata = x"11111111" report "write unsuccessful" severity error;
	-- s_write <= '0';
	
    m_load <= '1';
    wait for clk_period;
    m_load <= '0';

	wait;
	
end process;
	
end;