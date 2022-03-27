--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;			 -- package for io to write std_logic_vector

library std;
USE std.textio.all;						 -- package for io keywords: file_open()

ENTITY Pipelined_MIPS_Processor IS
	GENERIC(
		inst_ram_size : INTEGER := 4096;			-- BYTE ADDRESSABILITY; at most 1024 instructions
		data_ram_size : INTEGER := 32768;			-- BYTE ADDRESSABILITY; 8192 words data
		word_size : INTEGER := 32;
		byte_size : INTEGER := 8;
		mem_delay : time := 1 ns;			-- to make life easier, mem_dealy is 0.1 CC
		clock_period : time := 1 ns

		-- path definition
		dataoutput_filepath: string := "memory.txt";   -- only data memory output
        registeroutput_filepath : string := "register_file.txt";
		instruction_filepath : string := "program.txt"
	);
	PORT (
		clock       : in std_logic;            -- top level clock

		memload     : in std_logic;			-- signal to load initial instructions from "program.txt"	
		memoutput   : in std_logic			-- signal to write output file
	);
END Pipelined_MIPS_Processor;

ARCHITECTURE behavior OF Pipelined_MIPS_Processor IS 
    -- components declaration
    component Processor is 
    port(
        clock       : in std_logic;
        instruction : in std_logic_vector(wordsize-1 downto 0);
        read_data   : in std_logic_vector(wordsize-1 downto 0);
        
        pc          : out integer;
        data_addr   : out integer;
        write_req   : out std_logic;
        read_req    : out std_logic;
        write_data  : out std_logic_vector(wordsize-1 downto 0)
    );
    end component;

    component memory is 
    port(
        clock: in std_logic;
		writedata: in std_logic_vector(word_size-1 DOWNTO 0);  -- pass in a WORD; However, only data memory can be written
		memwrite: in std_logic;							-- write reqeust for data
		
		inst_address: in integer RANGE 0 TO inst_ram_size-1;
		data_address: in integer RANGE 0 TO data_ram_size-1;

		datamemread: in std_logic;						-- read request for data
		instmemread: in std_logic;						-- read request for instruction

		readdata: out std_logic_vector(word_size-1 DOWNTO 0);	-- pass out a WORD
		waitrequest: out std_logic;

		memload: in std_logic;			-- signal to load initial instructions from "program.txt"	
		memoutput: in std_logic			-- signal to write output file
    );
    end component;   

    -- local variables
    
    signal instruction  : std_logic_vector (wordsize-1 downto 0);
    signal read_data    : std_logic_vector (wordsize-1 downto 0);
    signal inst_addr    : integer range 0 to inst_ram_size-1;
    signal data_addr    : integer range 0 to data_ram_size-1;
    signal write_req    : std_logic;
    signal instread_req : std_logic;        -- instruction read request
    signal dataread_req : std_logic;        -- data read request
    signal write_data   : std_logic_vector(wordsize-1 downto 0);
    signal wait_request : std_logic;

BEGIN

    my_processor : processor
    port map(
        clock       => clock,
        instruction => instruction,
        read_data   => read_data,

        pc          => inst_addr,
        
        data_addr   => data_addr,
        write_req   => write_req,
        instread_req => instread_req,
        dataread_req => dataread_req,
        write_data  => write_data
    );

    mem : memory
    generic map(
        inst_ram_size   => inst_ram_size;			-- BYTE ADDRESSABILITY; at most 1024 instructions
		data_ram_size   => data_ram_size;			-- BYTE ADDRESSABILITY; 8192 words data
		word_size       => word_size;
		byte_size       => byte_size;
		mem_delay       => mem_delay;
		clock_period    => clock_period;
		dataoutput_filepath     => dataoutput_filepath
		instruction_filepath    => instruction_filepath
    );
    port map (
        clock       => clock,
        writedata   => write_data,
        memwrite    => write_req,   -- want to write the mem
        inst_address => inst_addr,
        data_address => data_addr,

        datamemread => dataread_req,
        instmemread => instread_req,

        readdata    => read_data,
        waitrequest => wait_request,

        memload     => memload,
        memoutput   => memoutput
    );