LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

USE work.INSTRUCTION_TOOLS.all;

ENTITY fetchStage_tb IS
END fetchStage_tb;

ARCHITECTURE behaviour OF fetchStage_tb IS

    constant bit_width : INTEGER := 32;
    constant memory_size : INTEGER := 8192;
    constant clock_period : time := 1 ns;
    
    COMPONENT fetchStage IS
        PORT (
            clock : in std_logic;
            reset : in std_logic;
            stall : in std_logic;
            instruction_out : out Instruction;
            PC : out integer;
            m_addr : out integer;
            m_read : out std_logic;
            m_readdata : in std_logic_vector (bit_width-1 downto 0);
            m_waitrequest : in std_logic -- unused until the Avalon Interface is added.
        );
    END COMPONENT;

    COMPONENT memory IS
        GENERIC(
            memory_size : INTEGER := memory_size;
            bit_width : INTEGER := bit_width;
            mem_delay : time := 0.1 ns;
            clock_period : time := clock_period
        );
        PORT (
            clock: IN STD_LOGIC;
            writedata: IN STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
            address: IN INTEGER;
            memwrite: IN STD_LOGIC;
            memread: IN STD_LOGIC;
            readdata: OUT STD_LOGIC_VECTOR (bit_width-1 DOWNTO 0);
            waitrequest: OUT STD_LOGIC;
            memdump : IN std_logic;
            memload : IN std_logic
        );
    END COMPONENT;

    --all the input signals with initial values
    signal clock : std_logic;
    signal reset : std_logic;
    signal stall : std_logic;
    signal instruction_out : Instruction;
    signal PC : integer;

    signal mem_addr : integer range 0 to memory_size-1;
    signal mem_read : std_logic;
    signal mem_readdata : std_logic_vector (bit_width-1 downto 0);
    signal mem_write : std_logic;
    signal mem_writedata : std_logic_vector (bit_width-1 downto 0);
    signal mem_waitrequest : std_logic; -- unused until the Avalon Interface is added.


    signal fetch_addr : integer;
    signal test_addr : integer range 0 to memory_size-1;

    signal memdump : std_logic := '0';
    signal memload : std_logic := '0';
    signal accessing_memory : std_logic;
BEGIN

    mem_addr <= test_addr when accessing_memory = '1' else fetch_addr;

    -- memory component which will be linked to the fetchStage under test.
    dut: memory 
    PORT MAP(
        clock,
        mem_writedata,
        mem_addr,
        mem_write,
        mem_read,
        mem_readdata,
        mem_waitrequest,
        memdump,
        memload
    );
    -- device under test.
    fet: fetchStage PORT MAP(
        clock=>clock,
        instmemread=>m_read,
        inst_address=>m_addr,
        readdata=>readbuffer
        -- mem_waitrequest -- unused until the Avalon Interface is added.
    );

    clk_process : process
    BEGIN
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;


    test_process : process
    variable test_instruction : INSTRUCTION;
    BEGIN
        assert PC = 0 report "PC is " & integer'image(PC) & " at the start of testing. (It should probably be 0!)" severity warning;
       
        reset <= '1';
        wait for clock_period;
        assert PC = 0 report "PC Should be 0 whenever reset is asserted (PC is "& integer'image(PC) & ")." severity error;
        reset <= '0';


        wait for clock_period;
        assert PC = 4 report "PC Should be 4 (one cycle after a reset)" severity error;

        branch_target <= 36;
        branch_condition <= '0';
        wait for clock_period;
        assert PC = 8 report "PC Should be 8, the branch should not be taken!" severity error;

        branch_condition <= '1';
        wait for clock_period;
        assert PC = 36 report "PC Should be 36 (the branch target), since branch condition is '1'." severity error;
        branch_condition <= '0';

        reset <= '1';
        wait for clock_period;
        assert PC = 0 report "PC Should be 0 whenever reset is asserted (second time)" severity error;
        reset <= '0';


        wait for clock_period;
        assert PC = 4 report "PC Should be 4 (one cycle after a reset, second time)" severity error;

        stall <= '1';
        wait for clock_period;
        assert PC = 4 report "PC should hold whenever stall is asserted." severity error;
        

        wait for clock_period;
        assert PC = 4 report "PC should hold whenever stall is asserted, even for multiple clock cycles." severity error;
        stall <= '0';        
        wait for clock_period;
        assert PC = 8 report "PC Should start incrementing normally again when stall is de-asserted." severity error;


        accessing_memory <= '1';
        test_addr <= 0;
        mem_write <= '1';
        test_instruction := makeInstruction("000000", 1,2,3,0, "100000"); -- ADD R1 R2 R3
        assert test_instruction.instruction_type = ADD report "The Instruction package failed to create the proper instruction!" severity failure;
        mem_writedata <= test_instruction.vector;
        wait until rising_edge(mem_waitrequest);
        accessing_memory <= '0';
        mem_write <= '0';

        reset <= '1';
        wait for clock_period;
        -- check if the fetchStage read instruction memory correctly.
        -- keep in mind, the "instruction" signal is the output of the fetch stage. It should match what we just wrote in memory.
        assert instruction_out.format = R_TYPE report "The output instruction does not have the right format! (Should have R Type)" severity error;
        assert instruction_out.instruction_type = ADD report "The output instruction does NOT have the right type (expecting Add)" severity error;
        assert instruction_out.rs = 1 report "Instruction RS is wrong! (got " & integer'image(instruction_out.rs) & ", was expecting 1" severity error;
        assert instruction_out.rt = 2 report "Instruction RT is wrong! (got " & integer'image(instruction_out.rt) & ", was expecting 2" severity error;
        assert instruction_out.rd = 3 report "Instruction RD is wrong! (got " & integer'image(instruction_out.rd) & ", was expecting 3" severity error;
        assert instruction_out.shamt = 0 report "Instruction shift amount should be 0." severity error;
        report "Done testing fetch stage." severity NOTE;
        wait;
    END PROCESS;

 
END;