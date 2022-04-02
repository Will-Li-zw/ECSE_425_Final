--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;			 -- package for io to write std_logic_vector

library std;
USE std.textio.all;						 -- package for io keywords: file_open()

ENTITY Pipelined_MIPS_Processor IS
    generic(
        inst_ram_size : INTEGER := 4096;			-- BYTE ADDRESSABILITY; at most 1024 instructions
		data_ram_size : INTEGER := 32768;			-- BYTE ADDRESSABILITY; 8192 words data
		word_size : INTEGER := 32;
		clock_period : time := 1 ns
	);
	PORT (
		clock       : in std_logic;            -- top level clock
        reset       : in std_logic;            -- highest-level reset signal

		memload     : in std_logic;			-- signal to load initial instructions from "program.txt"	
		memoutput   : in std_logic			-- signal to write output file
	);
END Pipelined_MIPS_Processor;

ARCHITECTURE behavior OF Pipelined_MIPS_Processor IS 
    -- components declaration
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
		inst_read_addr  : out std_logic_vector(word_size-1 downto 0);
        data_read_addr  : out std_logic_vector(word_size-1 downto 0);
        write_data  	: out std_logic_vector(word_size-1 downto 0)
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

    -- local variables
    
    signal instruction_bus  : std_logic_vector (word_size-1 downto 0);  -- instruction returned by mem
    signal data_bus         : std_logic_vector (word_size-1 downto 0);  -- data returned by mem
    signal read_data    : std_logic_vector (word_size-1 downto 0);
    signal inst_addr    : std_logic_vector (word_size-1 downto 0);
    signal data_addr    : std_logic_vector (word_size-1 downto 0);
    signal write_req    : std_logic;
    signal instread_req : std_logic := '0';        -- instruction read request
    signal dataread_req : std_logic := '0';        -- data read request
    signal write_data   : std_logic_vector(word_size-1 downto 0);
    signal wait_request : std_logic;

BEGIN
    -- define my processor
    my_processor : Processor
    port map(
        -- inputs
        clock       => clock,
        reset       => reset,
        instruction => instruction_bus, -- input inst from mem
        read_data   => data_bus,        -- input data from mem

        -- outputs
        datawrite_req => write_req,  -- request to write DATAMEM
        instread_req => instread_req,   -- request to read INSTMEM
        dataread_req => dataread_req,   -- request to read DATAMEM
        inst_read_addr => inst_addr,    -- instruction read target
        data_read_addr => data_addr,    -- data read target
        write_data  => write_data       -- provided data to write to memory: eg. STORE instruciton
    );

    mem : memory
    port map (
        clock       => clock,
        writedata   => write_data,
        memwrite    => write_req,   -- want to write the mem
        inst_address => inst_addr,
        data_address => data_addr,

        datamemread => dataread_req,
        instmemread => instread_req,

        readdata    => data_bus,
        readinst    => instruction_bus,
        waitrequest => wait_request,

        memload     => memload,
        memoutput   => memoutput
    );

END behavior;