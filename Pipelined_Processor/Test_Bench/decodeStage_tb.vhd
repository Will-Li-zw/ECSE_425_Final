LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY decodeStage_tb IS
END decodeStage_tb;
 
ARCHITECTURE behavior OF decodeStage_tb IS 

    -- COMPONENT register_file
    -- PORT(
    --     clk_rf : in std_logic;
    --     reset : in std_logic;

    --     r_reg1 : in std_logic_vector(4 downto 0);
    --     r_reg2 : in std_logic_vector(4 downto 0);
    --     w_reg : in std_logic_vector(4 downto 0);
    --     w_enable : in std_logic;
    --     w_data : in std_logic_vector(31 downto 0);

    --     r_data1 : out std_logic_vector(31 downto 0);
    --     r_data2 : out std_logic_vector(31 downto 0)
    --     );
    -- END COMPONENT;

    COMPONENT decode_stage
    generic(
        reg_adrsize : INTEGER := 32;
        ctrl_size : INTEGER := 7
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
   signal clk : std_logic;
   signal reset : std_logic;
   signal pc_in : std_logic_vector(31 downto 0);
   signal pc_out : std_logic_vector(31 downto 0);
   signal instruction_in : std_logic_vector (31 downto 0);

   signal w_addr : std_logic_vector(4 downto 0);
   signal w_data : std_logic_vector(31 downto 0);

   signal mem_reg : std_logic_vector(4 downto 0);
   signal stall_out : std_logic;

   signal rs_addr : std_logic_vector(4 downto 0);
   signal rt_addr : std_logic_vector(4 downto 0);
   signal rs_data : std_logic_vector(32-1 downto 0); -- contents of rs
   signal rt_data : std_logic_vector(32-1 downto 0); -- contents of rt
   signal imm_32 : std_logic_vector(32-1 downto 0);  -- sign extended immediate value
   signal jump_addr : std_logic_vector(32-1 downto 0);
   signal branch_addr : std_logic_vector(32-1 downto 0);

   -------- CTRL signals --------
   -- Register Write
   signal reg_write: std_logic; -- determine if a result needs to be written to a register
   signal reg_dst: std_logic; -- select the dst reg as either rs(R-type instruction) or rt(I-type instruction)
   signal mem_to_reg: std_logic;
   -- PC update
   signal jump: std_logic;
   signal branch: std_logic;
   -- Memory Access
   signal mem_read: std_logic;
   signal mem_write: std_logic;
   -- Source Operand Fetch
   signal alu_src: std_logic; -- select the second ALU input from either rt or sign-extended immediate
   -- ALU Operation
   signal alu_op: integer; -- ALU code for EXE

   -----------------------------register file intermediate---------------------------
   --Inputs
--    signal reset : std_logic := '0';
   signal w_enable : std_logic := '0';
--    signal r_reg1 : std_logic_vector(4 downto 0) := (others => '0');
--    signal r_reg2 : std_logic_vector(4 downto 0) := (others => '0');
--    signal w_reg : std_logic_vector(4 downto 0) := (others => '0');
--    signal w_data : std_logic_vector(31 downto 0) := (others => '0');

--    --Outputs
--    signal r_data1 : std_logic_vector(31 downto 0);
--    signal r_data2 : std_logic_vector(31 downto 0);

--    -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: decode_stage port map (
        clk => clk,
        reset => reset,
        pc_in=>pc_in,
        pc_out=>pc_out,
        instruction_in=>instruction_in,
        w_data=>w_data,
        w_addr=>w_addr,
        w_enable=>w_enable,
        mem_reg=>mem_reg,
        stall_out=>stall_out,
        rs_addr=>rs_addr,
        rt_addr=>rt_addr,
        rs_data=>rs_data,
        rt_data=>rt_data,
        imm_32=>imm_32,
        jump_addr=>jump_addr,
        branch_addr=>branch_addr,
        reg_write=>reg_write,
        reg_dst=>reg_dst,
        mem_to_reg=>mem_to_reg,
        jump=>jump,
        branch=>branch,
        mem_read=>mem_read,
        mem_write=>mem_write,
        alu_src=>alu_src,
        alu_op=>alu_op
   );

   -- Clock process definitions
   CLK_process :process
   begin
        clk <= '0';
		wait for CLK_period/2;
		clk <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
    --Test case 1 - 000000 01011 01100 01101 00000 100000   ADD R11,R12,R13
        wait for 1 ns;	
		w_enable 			<= '1';
		w_addr		<= "01100";
		w_data 	<= "00000000000000000000000000000100";--random 32bit
		wait for CLK_period;
		
        wait for 1 ns;	
		w_enable 			<= '1';
		w_addr		<= "01101";
		w_data 	<= "00000000000000000000000000000010";--random 32bit
		wait for CLK_period;
		w_enable <='0';
        pc_in <= (others => '0');
        assert pc_out <= "00000000000000000000000000000000" report "Test1: pc_out error" severity error;
        instruction_in <= "00000001011011000110100000100000";
        w_data <= (others => '0');
        w_addr <= (others => '0');
        w_enable <= '1';
        mem_reg <= (others => '0');

        assert stall_out <= '0' report "Test1: stall_out error" severity error;
        assert rs_addr <= "01011" report "Test1: rs_addr" severity error;
        assert rt_addr <= "01100" report "Test1: rt_addr" severity error;
        assert rs_data <= "00000000000000000000000000000100" report "Test1: rs_data" severity error;
        assert rt_data <= "00000000000000000000000000000010" report "Test1: rt_data" severity error;
        assert imm_32 <= "00000000000000000000000000000000" report "Test1: imm_32 error" severity error;
        assert jump_addr <= "00000000000000000000000000000000" report "Test1: jump_addr error" severity error;
        assert branch_addr <= "00000000000000000000000000000000" report "Test1: branch_addr error" severity error;
        -------- CTRL signals --------
        assert reg_write <= '1' report "Test1: reg_write error" severity error;
        assert reg_dst <= '1' report "Test1: reg_write error" severity error;
-- mem_to_reg: 0

-- -- PC update
-- Jump: 0
-- branch: 0
-- -- Memory Access
-- mem_read: 0
-- mem_write: 0
-- -- Source Operand Fetch
-- alu_src: 0 -- select the second ALU input from either rt or sign-extended immediate
-- -- ALU Operation
-- alu_op: 0 -- ALU code for EXE

      wait;
   end process;

END;