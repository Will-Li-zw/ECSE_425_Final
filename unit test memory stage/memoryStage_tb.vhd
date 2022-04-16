library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;	

entity memoryStage_tb is
end memoryStage_tb;

architecture behavior of memoryStage_tb is

component memory_stage is
generic(
    word_width: integer := 32;
    reg_addr_width: integer := 5 
);

port(
    clock: in std_logic;
    
    --input signals
    alu_result_in: in std_logic_vector (word_width-1 downto 0);
    reg_write_addr_in: in std_logic_vector (reg_addr_width-1 downto 0);
    mem_write_data_in: in std_logic_vector (word_width-1 downto 0);

    --input control signals
    reg_file_enable_in: in std_logic;
    mem_to_reg_flag_in: in std_logic;
    mem_write_request_in: in std_logic;
    mem_read_request_in: in std_logic;

    --output signals
    mem_write_data_out: out std_logic_vector (word_width-1 downto 0);
    mem_addr_out: out std_logic_vector (word_width-1 downto 0);
    alu_result_out: out std_logic_vector (word_width-1 downto 0);
    reg_write_addr_out: out std_logic_vector (reg_addr_width-1 downto 0);

    --output control signals
    mem_to_reg_flag_out: out std_logic;
    mem_write_request_out: out std_logic;
    mem_read_request_out: out std_logic;
    reg_file_enable_out: out std_logic;

    -- * Forwarding control * --          
    -- forwarding outputs:
    forwarding_mem_exe_reg_data : out std_logic_vector(word_width-1 downto 0);  -- MEM->EX forwarding, across one inst
    forwarding_mem_exe_reg_addr : out std_logic_vector(4 downto 0)
);
end component;

signal clk : std_logic := '0';
constant clk_period : time := 1 ns;

--input intermediate signals
signal alu_result_in: std_logic_vector (32-1 downto 0);
signal reg_write_addr_in: std_logic_vector (5-1 downto 0);
signal mem_write_data_in: std_logic_vector (32-1 downto 0);

--input intermediate control signals
signal reg_file_enable_in: std_logic;
signal mem_to_reg_flag_in: std_logic;
signal mem_write_request_in: std_logic;
signal mem_read_request_in: std_logic;

--output intermediate signals
signal mem_write_data_out: std_logic_vector (32-1 downto 0);
signal mem_addr_out: std_logic_vector (32-1 downto 0);
signal alu_result_out: std_logic_vector (32-1 downto 0);
signal reg_write_addr_out: std_logic_vector (5-1 downto 0);

--output intermediate control signals
signal reg_file_enable_out: std_logic;
signal mem_to_reg_flag_out: std_logic;
signal mem_write_request_out: std_logic;
signal mem_read_request_out: std_logic;

--output intermediate forwarding control
signal forwarding_mem_exe_reg_data : std_logic_vector(32-1 downto 0);  -- MEM->EX forwarding, across one inst
signal forwarding_mem_exe_reg_addr : std_logic_vector(4 downto 0);

begin
    memory: memory_stage port map(
        clock => clk,

        --input signals mapping
        alu_result_in => alu_result_in,
        reg_write_addr_in => reg_write_addr_in,
        mem_write_data_in => mem_write_data_in,

        --input control signals mapping
        reg_file_enable_in => reg_file_enable_in,
        mem_to_reg_flag_in => mem_to_reg_flag_in,
        mem_write_request_in => mem_write_request_in,
        mem_read_request_in => mem_read_request_in,
        
        --output signals mapping
        mem_write_data_out => mem_write_data_out,
        mem_addr_out => mem_addr_out,
        alu_result_out => alu_result_out,
        reg_write_addr_out => reg_write_addr_out,

        --output control signals mapping
        reg_file_enable_out => reg_file_enable_out,
        mem_to_reg_flag_out => mem_to_reg_flag_out,
        mem_write_request_out => mem_write_request_out,
        mem_read_request_out => mem_read_request_out,

        --forward controls mapping
        forwarding_mem_exe_reg_data => forwarding_mem_exe_reg_data,
        forwarding_mem_exe_reg_addr => forwarding_mem_exe_reg_addr
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

        report "Test1: signals passed correctly";

        alu_result_in <= x"00000001";
        reg_write_addr_in <= "00000";
        mem_write_data_in <= x"00000002";

        reg_file_enable_in <= '0';
        mem_to_reg_flag_in <= '1';
        mem_write_request_in <= '0';
        mem_read_request_in <= '1';

        wait until rising_edge(clk);
        wait for 0.1 ns;

        assert mem_write_data_out = x"00000002" report "Test 1: Error, mem write data not expected" severity error;
        assert mem_addr_out = x"00000001" report "Test 1: Error, mem address not expected" severity error;
        assert alu_result_out = x"00000001" report "Test 1: Error, alu result not expected" severity error;
        assert reg_write_addr_out = "00000" report "Test 1: Error, reg write address not expected" severity error;

        assert reg_file_enable_out = '0' report "Test 1: Error, reg_file_enable not expected" severity error;
        assert mem_to_reg_flag_out = '1' report "Test 1: Error, mem_to_reg_flag not expected" severity error;
        assert mem_write_request_out = '0' report "Test 1: Error, mem_write_request not expected" severity error;
        assert mem_read_request_out = '1' report "Test 1: Error, mem_read_request not expected" severity error;

        assert forwarding_mem_exe_reg_addr = "00000" report "Test 1: Error, forwarding_mem_exe_reg_addr not expected" severity error;
        assert forwarding_mem_exe_reg_data = x"00000001" report "Test 1: Error, forwarding_mem_exe_reg_data not expected" severity error;
    
        wait;
    
    end process;
        
    end;

