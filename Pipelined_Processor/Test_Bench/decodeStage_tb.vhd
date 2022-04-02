LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY register_file_tb IS
END register_file_tb;
 
ARCHITECTURE behavior OF register_file_tb IS 
  
    COMPONENT register_file
    generic(
         
    );
    PORT(
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
        rs_data : out std_logic_vector(reg_adrsize-1 downto 0); -- contents of rs
        rt_data : out std_logic_vector(reg_adrsize-1 downto 0); -- contents of rt
        imm_32 : out std_logic_vector(reg_adrsize-1 downto 0);  -- sign extended immediate value
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
        alu_op: out integer -- ALU code for EXE
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