--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;			 -- package for io to write std_logic_vector

library std;
USE std.textio.all;						 -- package for io keywords: file_open()

ENTITY memory IS
	-------------------------------------------------------------------------------
	-- This memory unit contains two separate array to store instuction and data --
	-- Each memory array is using little Endian -----------------------------------
	-------------------------------------------------------------------------------
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
END memory;

ARCHITECTURE behavior OF memory IS
	TYPE INST_MEM IS ARRAY(inst_ram_size-1 downto 0) OF STD_LOGIC_VECTOR(byte_size-1 DOWNTO 0);
	TYPE DATA_MEM IS ARRAY(data_ram_size-1 downto 0) OF STD_LOGIC_VECTOR(byte_size-1 DOWNTO 0);
	
	SIGNAL inst_ram_block: INST_MEM := (others=>(others=>'0'));   -- Initialize instruction memory to 0s
	SIGNAL data_ram_block: DATA_MEM := (others=>(others=>'0'));   -- Initialize data memory to 0s

	SIGNAL read_inst_addr_reg: INTEGER RANGE 0 to inst_ram_size-1;
	SIGNAL read_data_addr_reg: INTEGER RANGE 0 to data_ram_size-1;

	SIGNAL write_waitreq_reg: STD_LOGIC := '1';
	SIGNAL read_waitreq_reg: STD_LOGIC := '1';

	-- signal inst_addr_int : integer;
	-- signal data_addr_int : integer;


	-- load instructions from "program.txt"
	procedure load_instruction_from_file (signal mem : out INST_MEM) is
		file 	 f: text;			-- opened file
		variable aline: line;		-- a line
		variable instruction: std_logic_vector(word_size-1 DOWNTO 0);	-- turn line into std_logic_vector
		variable i: integer range 0 to inst_ram_size-1 := 0;	-- loop counter
	begin
		file_open(f, instruction_filepath, read_mode);
		L1: while i < inst_ram_size-1 loop		
			readline(f, aline);
			read(aline, instruction);
			-- parse instruction into 4 parts
			mem(i) <= instruction(7 downto 0);	-- NOTE: because I assign the signal, it needs to be defined as OUT signal in paramter
			mem(i+1) <= instruction(15 downto 8);
			mem(i+2) <= instruction(23 downto 16);
			mem(i+3) <= instruction(31 downto 24);
			i := i+4;	-- update counter by a word
			if (endfile(f)) then				-- if reached EOF, exit loop early
				exit L1;
			end if;
		end loop;
		file_close(f);
	end load_instruction_from_file;

	-- write the data memory to the file
	procedure output_data_to_file (mem : DATA_MEM) is
		file     	f  : text;
		variable aline : line;
		variable i: integer range 0 to inst_ram_size+4 := 0;	-- loop counter
	begin
		file_open(f, dataoutput_filepath, write_mode);
		L1: while i < inst_ram_size-1 loop
			write(aline, mem(i+3) & mem(i+2) & mem(i+1) & mem(i));		-- pass content of aline
			writeline(f, aline);		-- put line into the output file
			i := i+4;					-- update counter by 4(a word offset)
		end loop;
		file_close(f);
	end output_data_to_file;

BEGIN
	-- inst_addr_int <= to_integer( unsigned(inst_address) ); will cause sync error!
	-- data_addr_int <= to_integer( unsigned(data_address) );

    -- read initial
	read_process: PROCESS(memload)
	BEGIN
		IF (memload = '1') THEN
			load_instruction_from_file(inst_ram_block);
		END IF;
	END PROCESS;

	-- write file
	write_process: PROCESS(memoutput)
	BEGIN
		IF (memoutput'event AND memoutput = '1') THEN
			output_data_to_file(data_ram_block);
		END IF;
	END PROCESS;


	--This is the main section of the SRAM model
	mem_process: PROCESS (clock, inst_address, data_address)
	-- integer index for accessing the MEM ARRAY
	variable inst_addr_int : integer := 0;
	variable data_addr_int : integer := 0;
	BEGIN
		inst_addr_int := to_integer( unsigned(inst_address) );
		data_addr_int := to_integer( unsigned(data_address) );
		--This is the actual synthesizable SRAM block
		IF (clock'event AND clock = '0') THEN
			-- 1. mem write
			-- only data memory can be written
			IF (memwrite = '1') THEN
				data_ram_block(data_addr_int) <= writedata(7 downto 0);
				data_ram_block(data_addr_int+1) <= writedata(15 downto 8);
				data_ram_block(data_addr_int+2) <= writedata(23 downto 16);
				data_ram_block(data_addr_int+3) <= writedata(31 downto 24);
			END IF;
			
			-- 2. mem read 
			-- instruction read & data read could be parallel processing at same time.
			IF (instmemread = '1') THEN
				-- read_inst_addr_reg <= inst_address;
				readinst <= inst_ram_block(inst_addr_int+3) & inst_ram_block(inst_addr_int+2) 
								& inst_ram_block(inst_addr_int+1) & inst_ram_block(inst_addr_int);
			END IF;
			IF (datamemread = '1') THEN
				-- read_address_reg <= data_address;
				readdata <= data_ram_block(data_addr_int+3) & data_ram_block(data_addr_int+2)
								& data_ram_block(data_addr_int+1) & data_ram_block(data_addr_int);
			END IF;

		END IF;
	END PROCESS;
	-- readdata <= ram_block(read_address_reg);				TODO: why put this line outside of process?


	--The waitrequest signal is used to vary response time in simulation
	--Read and write should never happen at the same time.
	waitreq_w_proc: PROCESS (memwrite)
	BEGIN
		IF(memwrite'event AND memwrite = '1')THEN
			write_waitreq_reg <= '0' after 0.25 ns, '1' after 0.50 ns;
		END IF;
	END PROCESS;

	waitreq_r_proc: PROCESS (instmemread, datamemread)
	BEGIN
		IF((instmemread'event AND instmemread = '1') OR (datamemread'event AND datamemread = '1'))THEN
			read_waitreq_reg <= '0' after 0.25 ns, '1' after 0.50 ns;
		END IF;
	END PROCESS;
	waitrequest <= write_waitreq_reg and read_waitreq_reg;


END behavior;
