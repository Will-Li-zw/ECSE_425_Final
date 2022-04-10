--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity executeStage_tb is
end executeStage_tb;

architecture behavior of executeStage_tb is

component execute_stage is
    port(
        -- inputs --
        clk : in std_logic;
		read_data_1 : in signed(31 downto 0);       -- register data 1
        read_data_2 : in signed(31 downto 0);       -- register data 2
        ALUcontrol : in integer range 0 to 26;
        extended_lower_15_bits : in signed(31 downto 0); -- lower 16 bits (sign/zero extended to 32) passed in
        pc_plus_4 : in std_logic_vector(31 downto 0);
        
        -- reg address
        rt : in std_logic_vector(4 downto 0); 
        rs : in std_logic_vector(4 downto 0); -- may not need
        rd : in std_logic_vector(4 downto 0);
        
        -- control inputs:
		twomux_sel : in std_logic; -- choose read data 2 or immediate
		reg_file_enable_in : in std_logic;
        mem_to_reg_flag_in : in std_logic;
        mem_write_request_in : in std_logic;
        mem_read_request_in : in std_logic;
        
        -- outputs --
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
	
-- test signals 
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

-----------------
-- * inputs * --
-----------------
signal read_data_1 : signed(31 downto 0) := (others => '0');       -- register data 1
signal read_data_2 : signed(31 downto 0) := (others => '0');       -- register data 2
signal ALUcontrol : integer range 0 to 26;
signal extended_lower_15_bits : signed(31 downto 0) := (others => '0'); -- lower 16 bits (sign/zero extended to 32) passed in
signal pc_plus_4 : std_logic_vector(31 downto 0) := (others => '0');

-- reg address
signal rt : std_logic_vector(4 downto 0) := (others => '0'); 
signal rs : std_logic_vector(4 downto 0) := (others => '0'); -- may not need
signal rd : std_logic_vector(4 downto 0) := (others => '0');

-- control inputs:
signal twomux_sel : std_logic            := '0'; -- choose read data 2 or immediate
signal reg_file_enable_in : std_logic    := '0';
signal mem_to_reg_flag_in : std_logic    := '0';
signal mem_write_request_in : std_logic  := '0';
signal meme_read_request_in : std_logic  := '0';

-----------------
-- * outputs * --
-----------------
signal reg_address : std_logic_vector(4 downto 0);
-- register to be written (WB), for R type instrustion (reg_address = rd)
-- register to be loaded by memory data (MEM LW), for I type instrustion (reg_address = rt)
signal read_data_2_out : signed(31 downto 0); -- write_data for Mem
signal pc_plus_4_out : std_logic_vector(31 downto 0);
signal Addresult : signed(31 downto 0);
signal zero : std_logic;
signal ALUresult : signed(31 downto 0);
signal hi : signed(31 downto 0);
signal lo : signed(31 downto 0);
-- control outputs (TODO: may not be complete)
signal reg_file_enable_out : std_logic;
signal mem_to_reg_flag_out : std_logic;
signal mem_write_request_out : std_logic;
signal meme_read_request_out : std_logic;

begin

    -- Connect the components which we instantiated above to their
    -- respective signals.

    cut : execute_stage
    port map (
        clk         => clk,
		read_data_1 => read_data_1,
        read_data_2 => read_data_2,
        ALUcontrol  => ALUcontrol,
        extended_lower_15_bits => extended_lower_15_bits,
        pc_plus_4   => pc_plus_4,
        
        -- reg address
        rt => rt,
        rs => rs,
        rd => rd,
        
        -- control inputs:
		twomux_sel              => twomux_sel,
		reg_file_enable_in      => reg_file_enable_in,
        mem_to_reg_flag_in      => mem_to_reg_flag_in,
        mem_write_request_in    => mem_write_request_in,
        meme_read_request_in    => meme_read_request_in,
        
        -- outputs --
        reg_address => reg_address,
        read_data_2_out => read_data_2_out,
		pc_plus_4_out   => pc_plus_4_out,
        Addresult       => Addresult,
        zero            => zero,
		ALUresult       => ALUresult,
        hi => hi,
        lo => lo,
        -- control outputs (TODO: may not be complete)
        reg_file_enable_out     => reg_file_enable_out,
        mem_to_reg_flag_out     => mem_to_reg_flag_out,
        mem_write_request_out   => mem_write_request_out,
        meme_read_request_out   => meme_read_request_out
    );
                    
    -- clock loop
    clk_process : process  
    begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    end process;

    -- test process
    test_process : process
    begin
        
        wait for clk_period;
        -----------------------------------
        -- * TEST CODE START FROM HERE * --
        -----------------------------------
        report "Test1: Test 1+2 = 3";
        -- input1 <= x"00000001";
        -- input2 <= x"00000002";
        -- ALU_ctl<= 0;
        -- wait until rising_edge(clk);    
        -- assert ALU_res = x"00000003" report "Test1: Failed, ALU output not correct" severity error;

        read_data_1 <= x"00000001";
        read_data_2 <= x"00000002";
        ALUcontrol  <= 0;
        twomux_sel  <= '0';
        -- ALUcontrol  <= 2;
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult = x"00000003" report "Test1: Failed, ALU addition not correct" severity error;

        report "Test2-1: Test 3-4 = -1";
        read_data_1 <= x"00000003";
        read_data_2 <= x"00000004";
        ALUcontrol  <= 1;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult = x"FFFFFFFF" report "Test2-1: Failed, ALU subtraction not correct" severity error;

        report "Test2-2: Test 8-8 = 0";
        read_data_1 <= x"00000008";
        read_data_2 <= x"00000008";
        ALUcontrol  <= 1;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult = x"00000000" report "Test2-2: Failed, ALU subtraction not correct" severity error;

        report "Test3: Test 18*775 = 13950";
        read_data_1 <= x"00000012";
        read_data_2 <= x"00000307";
        ALUcontrol  <= 3;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert lo = x"0000367E" and hi=x"00000000" report "Test3: Failed, ALU multiplication not correct" severity error;


        report "Test4: Test 10/3 ";
        read_data_1 <= x"0000000A";
        read_data_2 <= x"00000003";
        ALUcontrol  <= 4;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert lo = x"00000003" and hi = x"00000001" report "Test4: Failed, ALU division not correct" severity error;

        report "Test5-1: Test slt and slti instruction: data1<op2";
        read_data_1 <= x"00000000";
        read_data_2 <= x"00000001";
        ALUcontrol  <= 5;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult=x"00000001" report "Test5-1: Failed, slt not correct" severity error;

        report "Test5-2: Test slt and slti instruction: data1>op2";
        read_data_1 <= x"00000001";
        read_data_2 <= x"00000000";
        ALUcontrol  <= 5;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult=x"00000000" report "Test5-2: Failed, slt not correct" severity error;

        report "Test6: Test AND instruction:";
        read_data_1 <= "01101000101111010101000101000010";
        read_data_2 <= "00100101010010100100100001000100";
        ALUcontrol  <= 7;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult="00100000000010000100000001000000" report "Test6: Failed, and not correct" severity error;

        report "Test7: Test OR instruction:";
        read_data_1 <= "01101000101111010101000101000010";
        read_data_2 <= "00100101010010100100100001000100";
        ALUcontrol  <= 8;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult = "01101101111111110101100101000110" report "Test7: Failed, or not correct" severity error;

        report "Test8: Test LUI instruction:";
        read_data_1 <= x"00000001";
        read_data_2 <= "10100101000111001000100000001001";
        ALUcontrol  <= 16;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult = "10001000000010010000000000000000" report "Test8: Failed, LUI not correct" severity error;

        report "Test9: Test SLL instruction:";
        read_data_1 <= x"00000008";
        read_data_2 <= x"00000004";
        ALUcontrol  <= 17;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult = x"00000080" report "Test9: Failed, SLL not correct" severity error;

        report "Test10: Test SRL instruction:";
        read_data_1 <= x"80000008";
        read_data_2 <= x"00000004";
        ALUcontrol  <= 18;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult = x"08000000" report "Test10: Failed, SRL not correct" severity error;

        report "Test11: Test SRA instruction:";
        read_data_1 <= x"80000008";
        read_data_2 <= x"00000004";
        ALUcontrol  <= 19;
        twomux_sel  <= '0';
        wait for clk_period;   -- wait after the rising edge
        assert ALUresult = x"F8000000" report "Test11: Failed, SRA not correct" severity error;

        -- LD AND ST are trivial...

        -- BNE AND BEQ are same as subtraction

        wait;

    end process;
	
end;