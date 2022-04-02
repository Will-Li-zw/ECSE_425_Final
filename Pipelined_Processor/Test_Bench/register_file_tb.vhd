LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY register_file_tb IS
END register_file_tb;
 
ARCHITECTURE behavior OF register_file_tb IS 
  
    COMPONENT register_file
    PORT(
        clk_rf : in std_logic;
        reset : in std_logic;

        r_reg1 : in std_logic_vector(4 downto 0);
        r_reg2 : in std_logic_vector(4 downto 0);
        w_reg : in std_logic_vector(4 downto 0);
        w_enable : in std_logic;
        w_data : in std_logic_vector(31 downto 0);

        r_data1 : out std_logic_vector(31 downto 0);
        r_data2 : out std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_rf : std_logic := '0';
   signal reset : std_logic := '0';
   signal w_enable : std_logic := '0';
   signal r_reg1 : std_logic_vector(4 downto 0) := (others => '0');
   signal r_reg2 : std_logic_vector(4 downto 0) := (others => '0');
   signal w_reg : std_logic_vector(4 downto 0) := (others => '0');
   signal w_data : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal r_data1 : std_logic_vector(31 downto 0);
   signal r_data2 : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: register_file PORT MAP (
          clk_rf => clk_rf,
          reset => reset,
          w_enable => w_enable,
          r_reg1 => r_reg1,
          r_reg2 => r_reg2,
          w_reg => w_reg,
          w_data => w_data,
          r_data1 => r_data1,
          r_data2 => r_data2
        );

   -- Clock process definitions
   CLK_process :process
   begin
        clk_rf <= '0';
		wait for CLK_period/2;
		clk_rf <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 1 ns;	

      -- insert stimulus here
		
		-- INSERT DATA TO REGISTER 1
		w_enable 			<= '1';
		r_reg1 		<= (others => '0');
		r_reg2		<= (others => '0');
		w_reg		<= "00001";
		w_data 	<= (others => '1');
		
		wait for CLK_period;
		
		-- READ DATA FROM REGISTER 1
		w_enable 			<= '0';
		r_reg1 		<= "00001";
		r_reg2		<= "00001";
		w_reg		<= (others => '0');
		w_data 	<= (others => '0');
		
      wait;
   end process;

END;