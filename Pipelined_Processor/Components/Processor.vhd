--This processor entity will connect five stages together
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;			 -- package for io to write std_logic_vector

library std;
USE std.textio.all;						 -- package for io keywords: file_open()

entity Processor is
-- TODO: haven't finished
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
end Processor;

architecture behavior of Processor is 
	-- components declaration
	component fetch_stage is 
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
    );
	end component;

	component decode_stage is 
	generic(
        reg_adrsize : INTEGER := 32;
        ctrl_size : INTEGER := 8
    );
    port (
        clk : in std_logic;
        reset : in std_logic;

        pc_in : in std_logic_vector(31 downto 0);
        pc_out : out std_logic_vector(31 downto 0);
        instruction_in : in std_logic_vector (31 downto 0);

        w_data : in std_logic_vector(31 downto 0);
        w_addr : in std_logic_vector(4 downto 0);
        w_enable : in std_logic;

        mem_reg : in std_logic_vector(4 downto 0);
        stall_out : out std_logic;

        rs_addr : out std_logic_vector(4 downto 0);
        rt_addr : out std_logic_vector(4 downto 0);
		rd_addr : out std_logic_vector(4 downto 0);             	-- destination register addr
        rs_data : out std_logic_vector(reg_adrsize-1 downto 0); 	-- contents of rs
        rt_data : out std_logic_vector(reg_adrsize-1 downto 0); 	-- contents of rt
        imm_32 : out std_logic_vector(reg_adrsize-1 downto 0);  	-- sign extended immediate value
        jump_addr : out std_logic_vector(reg_adrsize-1 downto 0);
        branch_addr : out std_logic_vector(reg_adrsize-1 downto 0);

        -------- CTRL signals --------
        -- Register Write
        reg_write: out std_logic; -- determine if a result needs to be written to a register
        reg_dst: out std_logic; -- select the dst reg as either rs(R-type instruction) or rt(I-type instruction)
        mem_to_reg: out std_logic;
        -- PC update
        jump: out std_logic;
        branch: out std_logic;
        -- Memory Access
        mem_read: out std_logic;
        mem_write: out std_logic;
        -- Source Operand Fetch
        alu_src: out std_logic; -- select the second ALU input from either rt or sign-extended immediate
        -- ALU Operation
        alu_op: out integer range 0 to 27 -- ALU code for EXE
    );
	end component;

	component execute_stage is 
	port(
        --------------
        -- *inputs* --
        --------------
        clk : in std_logic;
		read_data_1 : in signed(31 downto 0);       -- register data 1
        read_data_2 : in signed(31 downto 0);       -- register data 2
        ALUcontrol : in integer range 0 to 27;      -- interpreted op code from DECODE->EXE
        extended_lower_15_bits : in signed(31 downto 0); -- lower 16 bits (sign/zero extended to 32) passed in
        pc_plus_4 : in std_logic_vector(31 downto 0);   -- carried pc_next value from FET->DEC->EXE->...
        -- reg address
        rt : in std_logic_vector(4 downto 0); 
        rs : in std_logic_vector(4 downto 0); -- TODO: may not need??
        rd : in std_logic_vector(4 downto 0);
        -- control inputs:
		twomux_sel : in std_logic; -- choose read data 2 or immediate
        -- forwarding inputs:
        mem_exe_reg_data    : in signed(31 downto 0);                       -- account for MEM->EXE forwarding
        mem_exe_reg_addr    : in std_logic_vector(4 downto 0); 
        forwarded_exe_exe_reg_data    : in signed(31 downto 0);             -- account for EXE->EXE forwarding
        forwarded_exe_exe_reg_addr    : in std_logic_vector(4 downto 0);  
        ---------------
        -- *outputs* --
        ---------------
        -- forwarding outputs:
        forwarding_exe_exe_reg_data    : out signed(31 downto 0);           -- output forwarding to next CC EXE
        forwarding_exe_exe_reg_addr    : out std_logic_vector(4 downto 0); 
        reg_address : out std_logic_vector(4 downto 0);
        -- register to be written (WB), for R type instrustion (reg_address = rd)
		-- register to be loaded by memory data (MEM LW), for I type instrustion (reg_address = rt)
        read_data_2_out : out signed(31 downto 0); -- write_data for Mem
		pc_plus_4_out : out std_logic_vector(31 downto 0);
        Addresult : out signed(31 downto 0);
        zero : out std_logic;
		ALUresult : out signed(31 downto 0);
        hi : out signed(31 downto 0);
        lo : out signed(31 downto 0);  
        -- control outputs (TODO: may not be complete)
        reg_file_enable_out : out std_logic;
        mem_to_reg_flag_out : out std_logic;
        mem_write_request_out : out std_logic;
        meme_read_request_out : out std_logic
	);
	end component;

	-- component memory is 
	-- port(
	-- 	--
	-- );
	-- end component;

	-- component writeback is 
	-- port(
	-- 	--
	-- );
	-- end component;

	-- signals related to fetch:
	signal pc_out_fetch_decode	: std_logic_vector (word_size-1 downto 0);  -- next_pc value
	signal stall_req		: std_logic := '0';		-- stall req from DECODE
	signal ex_if_branch		: std_logic := '0'; 	-- branch req from EXECUTION
	signal de_if_jump		: std_logic := '0';		-- decode req from DECODE
	signal de_jump_addr		: std_logic_vector (word_size-1 downto 0); 	-- jump addr from DECODE
	signal ex_branch_addr	: std_logic_vector (word_size-1 downto 0);  -- calculated branch address
	signal inst_addr_buffer : std_logic_vector (word_size-1 downto 0);	-- instruciton address(pc) 

	-- signals related to decode: 
	signal pc_out_decode_execute : std_logic_vector (word_size-1 downto 0);  -- next_pc value
	signal write_back_data 	     : std_logic_vector (word_size-1 downto 0);  -- writeback data from WB stage
	signal write_back_reg		 : std_logic_vector (4 downto 0);		     -- writeback register addr from WB stage
	signal write_back_enable	 : std_logic;								 -- enable signal from WB stage
	signal mem_decode_reg	     : std_logic_vector (4 downto 0);			 -- from MEM->DECODE for judging stall
	signal decode_execute_rs_reg : std_logic_vector(4 downto 0);			 -- rs addr DECODE->EXE
	signal decode_execute_rt_reg : std_logic_vector(4 downto 0);			 -- rt addr DECODE->EXE
	signal decode_execute_rd_reg : std_logic_vector(4 downto 0);			 -- rd addr DECODE->...->WB->DEC to write register file
	signal decode_execute_rs_data: std_logic_vector(word_size-1 downto 0);	 -- rs data DECODE->EXE
	signal decode_execute_rt_data: std_logic_vector(word_size-1 downto 0);   -- rt data DECODE->EXE
	signal decode_execute_imme_data 	: std_logic_vector(word_size-1 downto 0);   -- immediate value DECODE->EXE
	signal decode_fetch_jump_addr		: std_logic_vector(word_size-1 downto 0);   -- jump addr DECODE->FETCH
	signal decode_execute_branch_addr	: std_logic_vector(word_size-1 downto 0);	-- branch addr DECODE->EXECUTE
	signal decode_execute_reg_write		: std_logic;	-- write register control DECODE->EXECUTE
	signal decode_execute_reg_dst		: std_logic;	-- TODO: maybe not useful
	signal decode_execute_mem_reg		: std_logic;	-- mem_reg to guide which result to Writeback DECODE->...->WB
	signal decode_execute_branch		: std_logic;    -- TODO: maybe not useful. If_branch is produced at EXECUTE stage
	signal decode_execute_mem_read		: std_logic;	-- mem read req to MEM, DECODE->...->MEM
	signal decode_execute_mem_write		: std_logic;	-- mem write req to MEM, DECODE->...->MEM
	signal decode_execute_alu_src		: std_logic;	-- alu_src control signal, DECODE->EXE
	signal decode_execute_alu_op		: integer range 0 to 27 := 0;	-- alu_op control signal, DECODE->EXE

	-- signals related to execute:
	signal pc_out_exe_mem 			: std_logic_vector (word_size-1 downto 0);  -- next_pc value
	signal forward_mem_exe_reg_data	: std_logic_vector(word_size-1 downto 0);   -- register value from MEM->EXE forwarding
	signal forward_mem_exe_reg_addr	: std_logic_vector(4 downto 0);				-- register addr from MEM->EXE forwarding
	signal forward_exe_exe_reg_data	: std_logic_vector(word_size-1 downto 0);	-- register value from EXE->EXE forwarding
	signal forward_exe_exe_reg_addr	: std_logic_vector(4 downto 0);	-- register addr from EXE->EXE forwarding
	signal exe_mem_or_wb_reg_addr	: std_logic_vector(4 downto 0);				-- register addr for WB or MEM load
	signal store_exe_mem_data		: std_logic_vector(word_size-1 downto 0);	-- output data for STORE instruction EXE->MEM
	signal exe_alu_result			: std_logic_vector(word_size-1 downto 0);	-- output of ALU calculation EXE->MEM
	signal exe_hi					: std_logic_vector(word_size-1 downto 0);	-- output of exe mul or div, hi32 bits
	signal exe_lo					: std_logic_vector(word_size-1 downto 0);	-- output of exe mul or div, lo32 bits

begin
	-- 连连看:
	fetcher : fetch_stage 
	port map(
		clock          => clock,		-- processor clock
		reset          => reset,		-- processor reset

		stall          => stall_req,		-- stall from decode
		if_branch      => ex_if_branch,
		if_jump        => de_if_jump,
		jump_addr      => de_jump_addr,
		branch_addr    => ex_branch_addr,

		pc             => inst_read_addr,
		pc_next        => pc_out_fetch_decode
   );

   decoder : decode_stage
   port map(
		clk 			=> clock,
		reset 			=> reset,
		-- fetch related 
		pc_in 			=> pc_out_fetch_decode,   -- pc_next from fetch->decode
		pc_out 			=> pc_out_decode_execute, -- pc_out from decode->execute
		instruction_in  => instruction,
		-- writeback related
		w_data 			=> write_back_data,
		w_addr 			=> write_back_reg,
		w_enable 	    => write_back_enable,
		-- stall for fetch
		mem_reg   => mem_decode_reg,
		stall_out => stall_req,					  -- stall that goes to fetch
		-- output register addr to following stage
		rs_addr   => decode_execute_rs_reg,		 
		rt_addr   => decode_execute_rt_reg,
		rd_addr	  => decode_execute_rd_reg,		 
		rs_data   => decode_execute_rs_data,	  
		rt_data   => decode_execute_rt_data,     
		imm_32    => decode_execute_imme_data,	  
		jump_addr => decode_fetch_jump_addr,
		branch_addr => decode_execute_branch_addr,

		-------- CTRL signals --------
		-- Register Write
		reg_write	=> decode_execute_reg_write, -- determine if a result needs to be written to a register
		reg_dst		=> decode_execute_reg_dst, -- select the dst reg as either rs(R-type instruction) or rt(I-type instruction)
		mem_to_reg  => decode_execute_mem_reg,
		-- PC update
		jump		=> de_if_jump,
		branch		=> decode_execute_branch,
		-- Memory Access
		mem_read	=> decode_execute_mem_read,
		mem_write	=> decode_execute_mem_write,
		-- Source Operand Fetch
		alu_src     => decode_execute_alu_src, -- select the second ALU input from either rt or sign-extended immediate
		-- ALU Operation
		alu_op		=> decode_execute_alu_op   -- ALU code for EXE
   );

   executer : execute_stage
   port map(
        clk 					=> clock,
		read_data_1 			=> signed(decode_execute_rs_data),
        read_data_2 			=> signed(decode_execute_rt_data),
        ALUcontrol 				=> decode_execute_alu_op,
        extended_lower_15_bits 	=> signed(decode_execute_imme_data),
        pc_plus_4 				=> pc_out_decode_execute,
        
        -- reg address
        rt => decode_execute_rt_reg,
        rs => decode_execute_rs_reg,
        rd => decode_execute_rd_reg,
        
        -- control inputs:
		twomux_sel 				=> decode_execute_alu_src,

        -- forwarding inputs:
        mem_exe_reg_data    	=> signed(forward_mem_exe_reg_data),
        mem_exe_reg_addr    	=> forward_mem_exe_reg_addr,
        forwarded_exe_exe_reg_data => signed(forward_exe_exe_reg_data),
        forwarded_exe_exe_reg_addr => forward_exe_exe_reg_addr,
        
        ---------------
        -- *outputs* --
        ---------------
        -- forwarding outputs:
        std_logic_vector(forwarding_exe_exe_reg_data) => forward_exe_exe_reg_data,       
        forwarding_exe_exe_reg_addr => forward_exe_exe_reg_addr,

        reg_address => exe_mem_or_wb_reg_addr,
        -- register to be written (WB), for R type instrustion (reg_address = rd)
		-- register to be loaded by memory data (MEM LW), for I type instrustion (reg_address = rt)
        std_logic_vector(read_data_2_out) 	=> store_exe_mem_data,
		pc_plus_4_out 						=> pc_out_exe_mem,
        std_logic_vector(Addresult)			=> ex_branch_addr,
        zero 			=> open,
		std_logic_vector(ALUresult) 		=> exe_alu_result,
        std_logic_vector(hi) 				=> exe_hi,
        std_logic_vector(lo) 				=> exe_lo,
        
        -- control outputs (TODO: may not be complete)
        reg_file_enable_out	 	=> open,
        mem_to_reg_flag_out 	=> open,
        mem_write_request_out 	=> open, 
        meme_read_request_out 	=> open
   );


	-- output instread_req
	instruction_read_req : process(reset)
	begin	
			-- when pc is available, output inst_read_req = '1'
			if reset = '1' then -- reset all control signal
				instread_req <= '0';
				datawrite_req<= '0';
				dataread_req <= '0';
			else
				instread_req <= '1';
			end if;
	end process;

end behavior;