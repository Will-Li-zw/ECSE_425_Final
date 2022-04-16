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
    inst_ram_size : INTEGER := 4096;			-- BYTE ADDRESSABILITY; at most 1024 instructions
    data_ram_size : INTEGER := 32768;			-- BYTE ADDRESSABILITY; 8192 words data
    word_size : INTEGER := 32;
    byte_size : INTEGER := 8;
    mem_delay : time := 1 ns;			-- to make life easier, mem_dealy is 0.1 CC
    clock_period : time := 1 ns;

    -- path definition
    dataoutput_filepath: string := "memory.txt";   -- only data memory output
    instruction_filepath : string := "program.txt"
);
port(
    clock: IN STD_LOGIC;
    writedata: IN STD_LOGIC_VECTOR (word_size-1 DOWNTO 0);  -- pass in a WORD; However, only data memory can be written
    memwrite: IN STD_LOGIC;							-- write reqeust for data
    
    inst_address: in std_logic_vector (word_size-1 DOWNTO 0);
	data_address: in std_logic_vector (word_size-1 DOWNTO 0);

    datamemread: IN STD_LOGIC;						-- read request for data
    instmemread: IN STD_LOGIC;						-- read request for instruction

    readdata: OUT STD_LOGIC_VECTOR (word_size-1 DOWNTO 0);	-- output data
    readinst: out std_logic_vector (word_size-1 DOWNTO 0);  -- output instruction
    waitrequest: OUT STD_LOGIC;

    memload: IN STD_LOGIC;			-- signal to load initial instructions from "program.txt"	
    memoutput: IN STD_LOGIC			-- signal to write output file
);
end component;
	
-- test signals 
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal i_addr : std_logic_vector(31 downto 0);      
signal d_addr : std_logic_vector(31 downto 0);         

signal i_read : std_logic := '0';
signal d_read : std_logic := '0';

signal m_readdata : std_logic_vector (31 downto 0);
signal m_readinst : std_logic_vector (31 downto 0);
signal m_write : std_logic := '0';
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

    datamemread => d_read,
    instmemread => i_read,

    readdata => m_readdata,
    readinst => m_readinst,
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
    
	wait for clk_period;
	
    m_load <= '1';
    wait for clk_period;
    m_load <= '0';

    wait for clk_period;
    wait for clk_period/2;

    -- try to read the instruction
    report "Test1: instruction memory read";
    i_addr <= x"00000000";
    i_read <= '1';
    wait until rising_edge(m_waitrequest);
    assert m_readinst = x"200B07D0" report "Test1: Failed, read instruction unsuccessful" severity error;
    i_read <= '0';

	wait for clk_period*1.5;

    -- try to read the instruction
    report "Test1-2: instruction memory read";
    i_addr <= x"00000004";
    i_read <= '1';
    wait until rising_edge(m_waitrequest);
    assert m_readinst = x"200F0004" report "Test1-2: Failed, read instruction unsuccessful" severity error;
    i_read <= '0';

    wait for clk_period*1.5;
	
    -- try to write the data memory
    report "Test2: data memory write";
    d_addr <= x"00000004";
    m_write <= '1';
    m_writedata <= x"100B0004";
    wait until rising_edge(m_waitrequest);
    m_write <= '0';
    d_addr <= x"00000004";    -- initiate a data read
    d_read <= '1';
    wait until rising_edge(m_waitrequest);
    -- wait for 0.1 ns;    -- solely for passing the test, 
    assert m_readdata = x"100B0004" report "Test2: Failed, write data unsuccessful" severity error; -- this passes the test actually. ignore
    d_read <= '0';

    wait for clk_period;  

    report "Test3: data memory I/O";
    m_output <= '1';
    wait for clk_period;
    m_output <= '0';


    -- try to read the instruction and memory at same time
    report "Test4: instruction+data memory read";
    i_addr <= x"00000004";
    i_read <= '1';
    d_addr <= x"00000000";    -- initiate a data read
    d_read <= '1';
    wait until rising_edge(m_waitrequest);
    assert m_readinst = x"200F0004" report "Test4-1: Failed, read instruction unsuccessful" severity error;
    assert m_readdata = x"00000000" report "Test4-2: Failed, write data unsuccessful" severity error; 
    i_read <= '0';
    d_read <= '0';
    wait for clk_period/2;
        
    -- try to read the instruction and write memory at same time
    report "Test5: instruction memory read + data write";
    i_addr <= x"00000008";
    i_read <= '1';
    d_addr <= x"00000008";
    m_write <= '1';
    m_writedata <= x"0C0B0A09";
    wait until rising_edge(m_waitrequest);
    assert m_readinst = x"20010003" report "Test5: Failed, read instruction unsuccessful" severity error;
    i_read <= '0';
    m_write <= '0';

    wait;

end process;
	
end;