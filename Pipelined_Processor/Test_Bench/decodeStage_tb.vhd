LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY decodeStage_tb IS
END decodeStage_tb;
 
ARCHITECTURE behavior OF decodeStage_tb IS 
    COMPONENT decode_stage
    generic(
        reg_adrsize : INTEGER := 32;
        ctrl_size : INTEGER := 8
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

        -- output request signal:
        reg_output: in std_logic;
        
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
   signal reset : std_logic:='0';
   signal pc_in : std_logic_vector(31 downto 0);
   signal pc_out : std_logic_vector(31 downto 0);
   signal instruction_in : std_logic_vector (31 downto 0);

   signal w_addr : std_logic_vector(4 downto 0);
   signal w_data : std_logic_vector(31 downto 0);

   signal mem_reg : std_logic_vector(4 downto 0);
   signal stall_out : std_logic;
   
   signal reg_output : std_logic;

   signal rs_addr : std_logic_vector(4 downto 0);
   signal rt_addr : std_logic_vector(4 downto 0);
   signal rs_data : std_logic_vector(32-1 downto 0); -- contents of rs
   signal rt_data : std_logic_vector(32-1 downto 0); -- contents of rt
   signal imm_32 : std_logic_vector(32-1 downto 0);  -- sign extended immediate value
   signal jump_addr : std_logic_vector(32-1 downto 0);

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
   --Inputs
   signal w_enable : std_logic := '0';
   -- Clock period definitions
   constant CLK_period : time := 1 ns;
 
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
        reg_output => reg_output,
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
    -- initialization
        wait for 0.5*CLK_period;	
        w_enable <= '1';
        w_addr <= "01100";
        w_data <= "00000000000000000000000000000100";--random 32bit
        
        wait for CLK_period;
        w_enable <= '1';
        w_addr <= "01101";
        w_data <= "00000000000000000000000000000010";--random 32bit

        wait for CLK_period;
        w_enable    <= '1';
        w_addr  <= "00001";
        w_data  <= "00000000000000000000000000001111";--random 32bit
        wait for CLK_period;
        
        wait for CLK_period;
        w_enable    <= '1';
        w_addr  <= "00010";
        w_data  <= "00000000000000000000000000000111";--random 32bit

--Test case 1 - 000000 01011 01100 01101 00000 100000   ADD R11,R12,R13
        report "Test 1 - ADD R11,R12,R13";
        w_enable <='0';
        pc_in <= (others => '0');
        assert pc_out <= "00000000000000000000000000000000" report "Test1: pc_out error" severity error;
        instruction_in <= "00000001011011000110100000100000";
        wait for 1 ns;

        assert stall_out <= '0' report "Test1: stall_out error" severity error;
        assert rs_addr <= "01011" report "Test1: rs_addr" severity error;
        assert rt_addr <= "01100" report "Test1: rt_addr" severity error;
        assert rs_data <= "00000000000000000000000000000100" report "Test1: rs_data" severity error;
        assert rt_data <= "00000000000000000000000000000100" report "Test1: rt_data" severity error;
        -------- CTRL signals --------jump_addr
        assert reg_write <= '1' report "Test1: reg_write error" severity error;
        assert reg_dst <= '1' report "Test1: reg_write error" severity error;

        reset <= '1';

    --Test case 2 - 000000 01010 01111 00000 00000 011000   MULT R10,R15,R0    R0=R10*R15
        report "Test 2 - MULT R10,R15,R0";
        wait for 1 ns; 
        w_enable    <= '1';
        w_addr  <= "01100";
        w_data  <= "00000000000000000000000000001100";--random 32bit
        wait for CLK_period;

        w_enable    <= '1';
        w_addr  <= "01101";
        w_data  <= "00000000000000000000000000000110";--random 32bit
        wait for CLK_period;

        w_enable <='0';
        pc_in <= (others => '0');
        assert pc_out <= "00000000000000000000000000000000" report "Test2: pc_out error" severity error;
        instruction_in <= "00000001010011110000000000011000";
        wait for 1 ns;

        assert stall_out <= '0' report "Test2: stall_out error" severity error;
        assert rs_addr <= "01010" report "Test2: rs_addr" severity error;
        assert rt_addr <= "01111" report "Test2: rt_addr" severity error;
        assert rs_data <= "00000000000000000000000000001100" report "Test2: rs_data" severity error;
        assert rt_data <= "00000000000000000000000000000110" report "Test2: rt_data" severity error;
        assert jump_addr <= "00000000000000000000000000000000" report "Test2: jump_addr error" severity error;
        -------- CTRL signals --------
        assert reg_write <= '1' report "Test2: reg_write error" severity error;
        assert reg_dst <= '1' report "Test2: reg_write error" severity error;

--Test case 3 - 10001100001000100000000000000000  LW R2, R1
        report "Test 3 - LW R2, R1";
        w_enable <='0';
        pc_in <= (others => '0');
        assert pc_out <= "00000000000000000000000000000000" report "Test3: pc_out error" severity error;
        instruction_in <= "10001100001000100000000000000000";
        w_data <= (others => '0');
        w_addr <= (others => '0');
        w_enable <= '0';
        mem_reg <= (others => '0');

        wait for 1 ns;
        assert stall_out <= '0' report "Test3: stall_out error" severity error;
        assert rs_addr <= "00001" report "Test3: rs_addr" severity error;
        assert rt_addr <= "00010" report "Test3: rt_addr" severity error;
        assert rs_data <= "00000000000000000000000000001111" report "Test3: rs_data" severity error;
        assert rt_data <= "00000000000000000000000000000111" report "Test3: rt_data" severity error;
        assert jump_addr <= "00000000000000000000000000000000" report "Test3: jump_addr error" severity error;
        -------- CTRL signals --------
        assert reg_write <= '1' report "Test3: reg_write error" severity error;
        assert mem_read <= '1' report "Test3: mem_read error" severity error;
        assert reg_dst <= '0' report "Test3: reg_dst error" severity error;
        
        --Test case 4 - 10001100001000100000000000000000  LW R2, R1
        report "Test 4 - SUB R1, R2, R4 R1=R2-R4";
        w_enable <='0';
        pc_in <= (others => '0');
        assert pc_out <= "00000000000000000000000000000000" report "Test4: pc_out error" severity error;
        instruction_in <= "00000000010001000000100000100010";
        w_data <= (others => '0');
        w_addr <= (others => '0');
        w_enable <= '0';
        mem_reg <= (others => '0');

        wait for 1 ns;
        assert stall_out <= '1' report "Test4: stall_out error" severity error;
        assert rs_addr <= "00010" report "Test4: rs_addr" severity error;
        assert rt_addr <= "00100" report "Test4: rt_addr" severity error;
        assert rs_data <= "00000000000000000000000000001111" report "Test4: rs_data" severity error;
        assert rt_data <= "00000000000000000000000000000111" report "Test4: rt_data" severity error;
        assert jump_addr <= "00000000000000000000000000000000" report "Test4: jump_addr error" severity error;
        -------- CTRL signals --------
        assert reg_write <= '1' report "Test4: reg_write error" severity error;
        assert mem_read <= '0' report "Test4: mem_read error" severity error;
        assert reg_dst <= '1' report "Test4: reg_dst error" severity error;
        
        --Test case 5 - 000000 01010 01111 00000 00000 011000   MULT R10,R15,R0    R0=R10*R15
        report "Test 5 - MULT R10,R15,R0";
        instruction_in <= "00000001010011110000000000011000";
    	wait for 1 ns;
    	   
        assert stall_out <= '0' report "Test5: stall_out error" severity error;
        assert rs_addr <= "01010" report "Test5: rs_addr" severity error;
        assert rt_addr <= "01111" report "Test5: rt_addr" severity error;
        assert rs_data <= "00000000000000000000000000001100" report "Test2: rs_data" severity error;
        assert rt_data <= "00000000000000000000000000000110" report "Test2: rt_data" severity error;
        assert jump_addr <= "00000000000000000000000000000000" report "Test2: jump_addr error" severity error;
        -------- CTRL signals --------
        assert reg_write <= '1' report "Test5: reg_write error" severity error;
        assert reg_dst <= '1' report "Test5: reg_write error" severity error;
      wait;
   end process;

END;

