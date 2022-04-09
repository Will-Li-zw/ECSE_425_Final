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
        meme_read_request_in : in std_logic;
        
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



begin

    -- Connect the components which we instantiated above to their
    -- respective signals.

    dut : memory
    port map (
        clock => clk,
        writedata => m_writedata,
        memwrite => m_write,
        
        inst_address => i_addr,
        data_address => d_addr,

        datamemread => d_read,
        instmemread => i_read,

        readdata => m_readdata,
        readinst => m_readinst,
        waitrequest => m_waitrequest,

        memload => m_load,
        memoutput => m_output
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
        
        m_load <= '1';
        wait for clk_period;
        m_load <= '0';

        wait for clk_period;
        wait for clk_period/2;

        -- try to read the instruction
        report "Test1: instruction memory read";
        i_addr <= x"00000000";
        i_read <= '1';
        wait until rising_edge(m_waitrequest);
        assert m_readinst = x"200B07D0" report "Test1: Failed, read instruction unsuccessful" severity error;
        i_read <= '0';

        wait for clk_period*1.5;

        -- try to read the instruction
        report "Test1-2: instruction memory read";
        i_addr <= x"00000004";
        i_read <= '1';
        wait until rising_edge(m_waitrequest);
        assert m_readinst = x"200F0004" report "Test1-2: Failed, read instruction unsuccessful" severity error;
        i_read <= '0';

        wait for clk_period*1.5;
        
        -- try to write the data memory
        report "Test2: data memory write";
        d_addr <= x"00000004";
        m_write <= '1';
        m_writedata <= x"100B0004";
        wait until rising_edge(m_waitrequest);
        m_write <= '0';
        d_addr <= x"00000004";    -- initiate a data read
        d_read <= '1';
        wait until rising_edge(m_waitrequest);
        -- wait for 0.1 ns;    -- solely for passing the test, 
        assert m_readdata = x"100B0004" report "Test2: Failed, write data unsuccessful" severity error; -- this passes the test actually. ignore
        d_read <= '0';

        wait for clk_period;  

        report "Test3: data memory I/O";
        m_output <= '1';
        wait for clk_period;
        m_output <= '0';


        -- try to read the instruction and memory at same time
        report "Test4: instruction+data memory read";
        i_addr <= x"00000004";
        i_read <= '1';
        d_addr <= x"00000000";    -- initiate a data read
        d_read <= '1';
        wait until rising_edge(m_waitrequest);
        assert m_readinst = x"200F0004" report "Test4-1: Failed, read instruction unsuccessful" severity error;
        assert m_readdata = x"00000000" report "Test4-2: Failed, write data unsuccessful" severity error; 
        i_read <= '0';
        d_read <= '0';
        wait for clk_period/2;
            
        -- try to read the instruction and write memory at same time
        report "Test5: instruction memory read + data write";
        i_addr <= x"00000008";
        i_read <= '1';
        d_addr <= x"00000008";
        m_write <= '1';
        m_writedata <= x"0C0B0A09";
        wait until rising_edge(m_waitrequest);
        assert m_readinst = x"20010003" report "Test5: Failed, read instruction unsuccessful" severity error;
        i_read <= '0';
        m_write <= '0';

        wait;

    end process;
	
end;