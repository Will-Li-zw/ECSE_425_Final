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
	-------------------------------------------------------------------------------
	GENERIC(
		inst_ram_size : INTEGER := 1024;			-- WORD ADDRESSABILITY; at most 1024 instructions
		data_ram_size : INTEGER := 8192;			-- WORD ADDRESSABILITY; 8192 words data
		word_size : INTEGER := 32;
		mem_delay : time := 0.1 ns;			-- to make life easier, mem_dealy is 0.1 CC
		clock_period : time := 1 ns;

		-- path definition
		dataoutput_filepath: string := "memory.txt";		-- TODO: is the output memory only for data?
		instruction_filepath : string := "program.txt"
	);
	PORT (
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
END memory;

ARCHITECTURE rtl OF memory IS
	TYPE INST_MEM IS ARRAY(inst_ram_size-1 downto 0) OF STD_LOGIC_VECTOR(word_size-1 DOWNTO 0);
	TYPE DATA_MEM IS ARRAY(data_ram_size-1 downto 0) OF STD_LOGIC_VECTOR(word_size-1 DOWNTO 0);
	
	SIGNAL inst_ram_block: INST_MEM := (others=>(others=>'0'));   -- Initialize instruction memory to 0s
	SIGNAL data_ram_block: DATA_MEM := (others=>(others=>'0'));   -- Initialize data memory to 0s

	SIGNAL read_inst_addr_reg: INTEGER RANGE 0 to inst_ram_size-1;
	SIGNAL read_data_addr_reg: INTEGER RANGE 0 to data_ram_size-1;

	SIGNAL write_waitreq_reg: STD_LOGIC := '1';
	SIGNAL read_waitreq_reg: STD_LOGIC := '1';


	-- load instructions from "program.txt"
	procedure load_instruction_from_file (signal mem : out INST_MEM) is
		file 	 f: text;			-- opened file
		variable aline: line;		-- a line
		variable instruction: std_logic_vector(word_size-1 DOWNTO 0);	-- turn line into std_logic_vector
	begin
		file_open(f, instruction_filepath, read_mode);
		for i in 0 to inst_ram_size-1 loop			-- TODO: what if filesize not upto inst_ram_size?
			readline(f, aline);
			read(aline, instruction);
			mem(i) <= instruction;
		end loop;
		file_close(f);
	end load_instruction_from_file;

	-- write the data memory to the file
	procedure output_data_to_file (mem : DATA_MEM) is
		file     	f  : text;
		variable aline : line;
	begin
		--TODO: Add generics for the paths
		file_open(f, dataoutput_filepath, write_mode);
		for i in 0 to data_ram_size-1 loop
			write(aline, mem(i));		-- pass content of aline
			writeline(f, aline);		-- put line into the output file
		end loop;
		file_close(f);
	end output_data_to_file;

BEGIN
    -- read initial
	read_process: PROCESS(memload)
	BEGIN
		IF (memload'event AND memload = '1') THEN
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
	mem_process: PROCESS (clock)
	BEGIN
		--This is the actual synthesizable SRAM block
		IF (clock'event AND clock = '1') THEN
			-- only data memory can be written
			IF (memwrite = '1') THEN
				data_ram_block(data_address) <= writedata;
			END IF;
			

			IF (instmemread = '1') THEN
				-- read_inst_addr_reg <= inst_address;
				readdata <= inst_ram_block(inst_address);
			END IF;
			IF (datamemread = '1') THEN
				-- read_address_reg <= data_address;
				readdata <= data_ram_block(data_address);
			END IF;

		END IF;
	END PROCESS;
	-- readdata <= ram_block(read_address_reg);				TODO: why put this line outside of process?


	--The waitrequest signal is used to vary response time in simulation
	--Read and write should never happen at the same time.
	waitreq_w_proc: PROCESS (memwrite)
	BEGIN
		IF(memwrite'event AND memwrite = '1')THEN
			write_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;
		END IF;
	END PROCESS;

	waitreq_r_proc: PROCESS (instmemread, datamemread)
	BEGIN
		IF((instmemread'event AND instmemread = '1') OR (datamemread'event AND datamemread = '1'))THEN
			read_waitreq_reg <= '0' after mem_delay, '1' after mem_delay + clock_period;
		END IF;
	END PROCESS;
	waitrequest <= write_waitreq_reg and read_waitreq_reg;


END rtl;
