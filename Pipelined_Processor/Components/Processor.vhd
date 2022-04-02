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
	component fetchStage is 
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

	-- component decode is 
	-- port(
	-- 	--
	-- );
	-- end component;

	-- component execute is 
	-- port(
	-- 	--
	-- );
	-- end component;

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

	-- signals:
	signal pc_next_value	: std_logic_vector (word_size-1 downto 0);  -- next_pc value

	signal stall_req		: std_logic := '0';		-- stall req from DECODE
	signal ex_if_branch		: std_logic := '0'; 	-- branch req from EXECUTION
	signal de_if_jump		: std_logic := '0';		-- decode req from DECODE
	signal de_jump_addr		: std_logic_vector (word_size-1 downto 0); 	-- jump addr from DECODE
	signal ex_branch_addr	: std_logic_vector (word_size-1 downto 0);
	signal inst_addr_buffer : std_logic_vector (word_size-1 downto 0);

begin
	-- 连连看:
	fetcher : fetchStage 
	port map(
      clock          => clock,		-- processor clock
      reset          => reset,		-- processor reset

      stall          => stall_req,		-- stall from decode
      if_branch      => ex_if_branch,
      if_jump        => de_if_jump,
      jump_addr      => de_jump_addr,
      branch_addr    => ex_branch_addr,

      pc             => inst_read_addr,
      pc_next        => pc_next_value
   );


   	--inst_read_addr <= inst_addr_buffer;	 -- might cause sync error

	-- output instread_req
	instruction_read : process(reset)
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