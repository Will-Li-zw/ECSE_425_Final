LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--USE ieee.numeric_std.ALL;
 
ENTITY fetchStage_tb IS
END fetchStage_tb;
 
ARCHITECTURE behavior OF fetchStage_tb IS 
  
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
    

   --Inputs
   signal clk           : std_logic := '0';
   signal reset         : std_logic := '0';
   signal stall         : std_logic := '0';
   signal t_if_branch   : std_logic := '0';
   signal t_if_jump     : std_logic := '0';
   signal t_jump_addr   : std_logic_vector(31 downto 0) := (others => '0');
   signal t_branch_addr : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal pc            : std_logic_vector (31 downto 0) := (others => '0');
   signal pc_next       : std_logic_vector (31 downto 0) := (others => '0');

   -- Clock period definitions
   constant clk_period  : time := 1 ns;
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   dut: fetch_stage 
   port map(
      clock          => clk,
      reset          => reset,
      stall          => stall,
      if_branch      => t_if_branch,
      if_jump        => t_if_jump,
      jump_addr      => t_jump_addr,
      branch_addr    => t_branch_addr,

      pc             => pc,
      pc_next        => pc_next
   );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		

      wait for clk_period;
      -- insert stimulus here 
		 --Inputs
		
      report "Test1: reset function";
		reset <= '1';
		wait for clk_period;
      assert pc = x"00000000" report "Test1: Failed, reset does not work for pc" severity error;
      assert pc_next = x"00000000" report "Test1: Failed, reset does not work for pc_next" severity error;
		reset <= '0';
		
      report "Test2: normal pc addition";
		wait for 5*clk_period;
      assert pc = x"00000010" report "Test2: Failed, pc value is not correct" severity error;
      assert pc_next = x"00000014" report "Test2: Failed, pc_next value is not correct" severity error;

		
      report "Test3: branch test";
		--if_jump_addr <= (others => '0');
		t_branch_addr <= x"000000F0";
		t_if_branch   <= '1';
		t_if_jump     <= '0';
		wait for clk_period;
      assert pc = x"000000F0" report "Test3: Failed, pc value is not correct" severity error;
      assert pc_next = x"000000F4" report "Test3: Failed, pc_next value is not correct" severity error;
		t_if_branch   <= '0';
		t_if_jump     <= '0';	

		wait for clk_period;
	
      report "Test4: jump test";
		t_jump_addr   <= x"00000050";
		t_if_branch   <= '0';
		t_if_jump     <= '1';
		wait for clk_period;
      assert pc = x"00000050" report "Test4: Failed, pc value is not correct" severity error;
      assert pc_next = x"00000054" report "Test4: Failed, pc_next value is not correct" severity error;
		t_if_branch   <= '0';
		t_if_jump     <= '0';
		
      wait;
   end process;

END behavior;
