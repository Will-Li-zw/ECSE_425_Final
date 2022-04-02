library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;	

entity writebackStage_tb is
end writebackStage_tb;

architecture behavior of writebackStage_tb is

component writebackStage is
generic(
    word_width: integer := 32;
    reg_address_width: integer := 5 
);

port(
    clock: in std_logic;
    
    read_data: in std_logic_vector (word_width-1 downto 0);
    alu_result: in std_logic_vector (word_width-1 downto 0);
    reg_address_in: in std_logic_vector (reg_address_width-1 downto 0);
    mem_to_reg_flag: in std_logic;
    reg_file_enable_in: in std_logic;

    reg_file_enable_out: out std_logic;
    reg_address_out: out std_logic_vector (reg_address_width-1 downto 0);
    write_data: out std_logic_vector (word_width-1 downto 0)
);
end component;

signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

signal m_read_data : std_logic_vector (31 downto 0);
signal alu_result : std_logic_vector (31 downto 0);
signal reg_address_in : std_logic_vector (4 downto 0);
signal mem_to_reg_flag : std_logic;
signal reg_file_enable_in : std_logic;

signal reg_file_enable_out : std_logic;
signal reg_address_out: std_logic_vector (5-1 downto 0);
signal write_data: std_logic_vector (32-1 downto 0);

begin
    writeback: writebackStage port map(
        clock => clk,

        read_data => m_read_data,
        alu_result => alu_result,
        reg_address_in => reg_address_in,
        mem_to_reg_flag => mem_to_reg_flag,
        reg_file_enable_in => reg_file_enable_in,

        reg_file_enable_out => reg_file_enable_out,
        reg_address_out => reg_address_out,
        write_data => write_data
    );

    clk_process : process  
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    test_process : process
    begin
        wait for clk_period;

        report "Test1: write back from ALU result";

        reg_file_enable_in <= '0';
        reg_address_in <= "00000";

        mem_to_reg_flag <= '0';
        alu_result <= x"00000001";
        m_read_data <= x"00000002";

        wait until rising_edge(clk);
        wait for 0.1 ns;

        assert reg_file_enable_out = '0' report "Test 1: Error, enable value not expected" severity error;
        assert reg_address_out = "00000" report "Test 1: Error, register address not expected" severity error;
        assert write_data = x"00000001" report "Test 1: Error, write data not expected" severity error;

        wait for clk_period;

        report "Test2: write back from MEM result";

        reg_file_enable_in <= '1';
        reg_address_in <= "11111";

        mem_to_reg_flag <= '1';
        alu_result <= x"00000001";
        m_read_data <= x"00000002";

        wait until rising_edge(clk);
        wait for 0.1 ns;

        assert reg_file_enable_out = '1' report "Test 2: Error, enable value not expected" severity error;
        assert reg_address_out = "11111" report "Test 2: Error, register address not expected" severity error;
        assert write_data = x"00000002" report "Test 2: Error, write data not expected" severity error;
    
        wait;
    
    end process;
        
    end;


