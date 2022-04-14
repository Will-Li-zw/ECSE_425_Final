--Adapted from Example 12-15 of Quartus Design and Synthesis handbook
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALUUnit_tb is
end ALUUnit_tb;

architecture behavior of ALUUnit_tb is

component ALU is
    PORT(
			data1 : IN SIGNED(31 DOWNTO 0);
			op2 : IN SIGNED (31 DOWNTO 0); -- output from a 2MUX (either data2 or instruct(15 downto 0))
			ALUcontrol : IN INTEGER range 0 to 26; --sequential encoding based on page 2 of the pdf

			ALUresult : OUT SIGNED(31 DOWNTO 0);
            hi : OUT SIGNED(31 DOWNTO 0);
			lo : OUT SIGNED(31 DOWNTO 0);

			zero : OUT STD_LOGIC
       );
end component;
	
-- test signals 
signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal input1 : signed(31 downto 0);
signal input2 : signed(31 downto 0);
signal ALU_ctl: integer range 0 to 26;
signal ALU_res: signed(31 downto 0);
signal hi_tst : signed(31 downto 0);
signal lo_tst : signed(31 downto 0);
signal zero_tst: std_logic;


begin

    -- Connect the components which we instantiated above to their
    -- respective signals.

    cut : ALU
    port map (
            data1       => input1,
			op2         => input2,
			ALUcontrol  => ALU_ctl,

			ALUresult   => ALU_res,
            hi          => hi_tst,
			lo          => lo_tst,
			zero        => zero_tst
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
        
        wait for clk_period/2;  -- wait for half clock cycle
        -- ------------------------------* TEST CODE START FROM HERE *------------------------------
        report "Test1: Test 1+2 = 3";
        input1 <= x"00000001";
        input2 <= x"00000002";
        ALU_ctl<= 0;
        wait until rising_edge(clk);    
        assert ALU_res = x"00000003" report "Test1: Failed, ALU output not correct" severity error;

        wait for clk_period;

        report "Test2: Test 2-1 = 1";
        input1 <= x"00000002";
        input2 <= x"00000001";
        ALU_ctl<= 1;
        wait until rising_edge(clk);    
        assert ALU_res = x"00000001" report "Test2: Failed, ALU output not correct" severity error;

        wait for clk_period;

        report "Test3: Test 2+3 Immediate";
        input1 <= x"00000002";
        input2 <= x"00000003";
        ALU_ctl<= 2;
        wait until rising_edge(clk);    
        assert ALU_res = x"00000005" report "Test3: Failed, ALU output not correct" severity error;

        wait for clk_period;

        report "Test4: Test 2*3 = 6";
        input1 <= x"00000002";
        input2 <= x"00000003";
        ALU_ctl<= 3;
        wait until rising_edge(clk); 
        assert lo_tst = x"00000006" report "Test4: Failed, ALU output not correct" severity error;

        wait for clk_period;
      
        report "Test5: Test for large value multi";
        input1 <= x"ffffffff";
        input2 <= x"ffffffff";
        ALU_ctl<= 3;
        wait until rising_edge(clk); 
        assert lo_tst = x"00000000" report "Test5 low: Failed, ALU output not correct" severity error;
        assert hi_tst = x"FFFFFFFE" report "Test5 high: Failed, ALU output not correct" severity error;

        wait for clk_period;
      
        report "Test6: Test 6/2 = 3";
        input1 <= x"00000006";
        input2 <= x"00000002";
        ALU_ctl<= 4;
        wait until rising_edge(clk); 
        assert lo_tst = x"00000003" report "Test6: Failed, ALU output not correct" severity error;
        assert hi_tst = x"00000000" report "Test6: Failed, ALU output not correct" severity error;

        wait for clk_period;

        report "Test6: Test 7/2 = 3.....1";
        input1 <= x"00000007";
        input2 <= x"00000002";
        ALU_ctl<= 4;
        wait until rising_edge(clk); 
        assert lo_tst = x"00000003" report "Test6: Failed, ALU output not correct" severity error;
        assert hi_tst = x"00000001" report "Test6: Failed, ALU output not correct" severity error;

        wait for clk_period;

        report "Test7: Test set less than";
        input1 <= x"00000006";
        input2 <= x"00000002";
        ALU_ctl<= 5;
        wait until rising_edge(clk); 
        assert zero_tst = ’0‘ report "Test7: Failed, ALU output not correct" severity error;

        wait for clk_period;

        report "Test8: Test 5 and 3 = 3";
        input1 <= x"00000005";
        input2 <= x"00000003";
        ALU_ctl<= 7;
        wait until rising_edge(clk); 
        assert  ALU_res = x"00000003" report "Test8: Failed, ALU output not correct" severity error;

        wait for clk_period;
        -- finish;

        wait;

    end process;
	
end;