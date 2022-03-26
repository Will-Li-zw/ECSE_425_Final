LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

--USE ieee.numeric_std.ALL;
 
ENTITY fetchStage_tb IS
END fetchStage_tb;
 
ARCHITECTURE behavior OF fetchStage_tb IS 
  
    COMPONENT fetcher
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         if_ctrl_pcSrc : IN  std_logic;
         if_jump_addr : IN  std_logic_vector(31 downto 0);
         if_ctrl_jump : IN  std_logic;
        --  if_branchAddr : IN  std_logic_vector(31 downto 0);
         pc : OUT  std_logic_vector(31 downto 0);
         instruction_out : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal if_ctrl_pcSrc : std_logic := '0';
   signal if_jump_addr : std_logic_vector(31 downto 0) := (others => '0');
   signal if_ctrl_jump : std_logic := '0';
   signal if_branchAddr : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal pc : std_logic_vector(31 downto 0);
   signal instruction_out : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fetcher PORT MAP (
          clk => clk,
          reset => reset,
          if_ctrl_pcSrc => if_ctrl_pcSrc,
          if_jump_addr => if_jump_addr,
          if_ctrl_jump => if_ctrl_jump,
          if_branchAddr => if_branchAddr,
          pc => pc,
          instruction_out => instruction_out
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
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		 --Inputs
		
		reset <= '1';
		
		wait for clk_period*10;
		reset <= '0';
		
		wait for clk_period*100;
		
		--if_jump_addr <= (others => '0');
		if_branchAddr <= "00000000000000000000000011110000";

		
		if_ctrl_pcSrc <= '1';
		if_ctrl_jump <= '0';
		wait for clk_period;
		
		if_ctrl_pcSrc <= '0';
		if_ctrl_jump <= '0';
		
		wait for clk_period*100;
		
		if_jump_addr <= "00000000000000000000000000000010";
		
		
		if_ctrl_pcSrc <= '1';
		if_ctrl_jump <= '1';
		wait for clk_period;
		
		
		if_ctrl_pcSrc <= '0';
		if_ctrl_jump <= '0';
		
		
      wait;
   end process;

END;