library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity newFetchStage is
    port (
        clk: in std_logic;
        reset: in std_logic;
        stall: in std_logic:='0';
        stall_number: in std_logic_vector(31 downto 0):=(others=>'0');
        processor_enable: in std_logic:='0';

        -- input from WB
        if_jump_addr: in std_logic_vector (31 downto 0):=(others=>'0'); --TODO: from decode stage
        if_branchAddr: in std_logic_vector (31 downto 0):=(others=>'0'); -- TODO: from memory step
        if_ctrl_pcSrc: in std_logic := '0';
        if_ctrl_jump: in std_logic := '0';

        -- output
        pc: out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
        instruction_out: out STD_LOGIC_VECTOR (31 downto 0) := (others => '0')
    );
end newFetchStage;

architecture implementation of newFetchStage is
    component TWOMUX is
		Port (
			sel : IN STD_LOGIC;
			input0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;

    component ADDER is
        port (
            X: in std_logic_vector(31 downto 0);
            Y: in std_logic_vector(31 downto 0);
            CIN: in std_logic;
            COUT: out std_logic;
            R: out std_logic_vector(31 downto 0)
        );
    end component;

    signal adder1_output: std_logic_vector(31 downto 0):=(others=>'0');
    signal pc_register: std_logic_vector(31 downto 0):=(others=>'0');
    signal mux_branch_output: std_logic_vector(31 downto 0):=(others=>'0');
    signal temp_output: std_logic_vector(31 downto 0):=(others=>'0');
    signal mux_jump_output: std_logic_vector(31 downto 0):=(others=>'0');
	signal mux_stall_output: std_logic_vector(31 downto 0):=(others=>'0');

begin

    -- TODO: MUX branch
    mux_branch: TWOMUX port map(
        sel => if_ctrl_pcSrc,
        input0 => adder1_output,
        input1 => if_branchAddr,
        output => mux_branch_output
    );

    mux_jump : TWOMUX port map(
	    sel => if_ctrl_jump,	
        input0 => mux_branch_output,
        input1 => if_jump_addr,
        output => mux_jump_output
	);

    staller : TWOMUX port map(
	    sel => stall,	
        input0 => mux_jump_output,
        input1 => stall_number,
        output => mux_stall_output
	);

    adder1: ADDER port map(
        X=>pc_register,
        Y=>"00000000000000000000000000000001",
        CIN=>'0',
        R=>adder1_output
    );

    fetch: process(clk,reset)
    begin
        if reset='1' or processor_enable='0' then
            pc <= (others=>'0');
            instruction_out <= (others=>'0');
            pc_register<=(others=>'0');
        elsif rising_edge(clk) then
            pc_register <=mux_stall_output;
            pc <= adder1_output;
            instruction_out<=mux_stall_output;
        end if;
    end process;
end implementation; 

