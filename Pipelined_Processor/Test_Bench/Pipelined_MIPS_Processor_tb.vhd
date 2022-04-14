--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;			 -- package for io to write std_logic_vector

entity Pipelined_MIPS_Processor_tb is
end Pipelined_MIPS_Processor_tb;

architecture behavior of Pipelined_MIPS_Processor_tb is
-- component under test:
component Processor is
    generic(
		clock_period : time := 1 ns;
		word_size : INTEGER := 32;
		registeroutput_filepath : string := "register_file.txt"
	);
	port (
		clock       : in std_logic;
		reset 		: in std_logic;

        instruction : in std_logic_vector(word_size-1 downto 0);
        read_data   : in std_logic_vector(word_size-1 downto 0);
        
        datawrite_req   : out std_logic;
        instread_req	: out std_logic;
        dataread_req	: out std_logic;
		inst_addr       : out std_logic_vector(word_size-1 downto 0);
        data_addr       : out std_logic_vector(word_size-1 downto 0);
        write_data  	: out std_logic_vector(word_size-1 downto 0);

        mem_output  : out std_logic
	);
end component;

component memory is
    GENERIC(
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
	PORT (
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
signal reset : std_logic := '0';
constant clk_period : time := 1 ns;

signal instruction_bus  : std_logic_vector (31 downto 0);  -- instruction returned by mem
signal data_bus         : std_logic_vector (31 downto 0);  -- data returned by mem
signal read_data        : std_logic_vector (31 downto 0);
signal inst_addr        : std_logic_vector (31 downto 0);
signal data_addr        : std_logic_vector (31 downto 0);
signal write_data   : std_logic_vector(31 downto 0);
-- control signals
signal write_req    : std_logic := '0';         -- data write request
signal instread_req : std_logic := '0';        -- instruction read request
signal dataread_req : std_logic := '0';        -- data read request


signal m_load       : std_logic := '0';
signal m_output     : std_logic := '0';
signal wait_request : std_logic;



begin

-- Connect the components which we instantiated above to their
-- respective signals.
 -- define my processor
    my_processor : Processor
    port map(
    -- inputs
        clock       => clk,
        reset       => reset,
        instruction => instruction_bus, -- input inst from mem
        read_data   => data_bus,        -- input data from mem

        -- outputs
        datawrite_req   => write_req,  -- request to write DATAMEM
        instread_req => instread_req,   -- request to read INSTMEM
        dataread_req => dataread_req,   -- request to read DATAMEM
        inst_addr => inst_addr,    -- instruction read target
        data_addr => data_addr,    -- data read target
        write_data  => write_data,       -- provided data to write to memory: eg. STORE instruciton

        mem_output => m_output
    );

 
    my_mem : memory
    port map (
        clock       => clk,
        writedata   => write_data,
        memwrite    => write_req,
        
        inst_address=> inst_addr,
        data_address=> data_addr,

        datamemread => dataread_req,
        instmemread => instread_req,

        readdata    => data_bus,
        readinst    => instruction_bus,
        waitrequest => wait_request,

        memload     => m_load,
        memoutput   => m_output
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
        m_load <= '1';
        reset  <= '1';
        wait for clk_period;
        reset  <= '0';
        m_load <= '0';

        wait for clk_period;
        wait for clk_period/2;  -- here's rising edge of clk



        wait;                   -- wait for program to run

    end process;
	
end behavior;