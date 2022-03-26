library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity newFetchStage is
    port (
        clk: in std_logic;
        reset: in std_logic;
        stall: in std_logic:='0';
        stall_number: in std_logic_vector(31 downto 0):=(other=>'0');
        processor_enable: in std_logic:='0';

        -- input from WB
        if_jump_addr: in std_logic_vector (31 downto 0):=(others=>'0'); --TODO: from decode stage
        if_branchAddr: in std_logic_vector (31 downto 0):=(others=>'0'); -- TODO: from memory step
        

        -- output
        pc: out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
        instruction_out: out STD_LOGIC_VECTOR (31 downto 0) := (others => '0')
    );
end newFetchStage;

architecture implementation of newFetchStage is
    component MUX is
		generic (

        ); 
		Port (
			sel : IN STD_LOGIC;
			input0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;

    component ADDER is
        generic (

        );
        port (
            X: in std_logic_vector(31 downto 0);
            Y: in std_logic_vector(31 downto 0);
            CIN: in std_logic;
            COUT: out std_logic;
            R: out std_logic
        );
    end component;

    signal adder1_output: std_logic_vector(31 downto 0):=(others=>'0');
    signal pc_register: std_logic_vector(31 downto 0):=(others=>'0');