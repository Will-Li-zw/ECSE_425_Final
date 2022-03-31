library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetchStage is
    generic(
        memory_size: integer := 8192; --data memory size is 8192 lines
        bit_width: integer := 32
    );

    port(
        clock: in std_logic; --required
        reset: in std_logic; --required
        stall: in std_logic; --required

        -- input from WB
        jump_addr: in std_logic_vector (31 downto 0):=(others=>'0'); --TODO: from decode stage
        branch_addr: in std_logic_vector (31 downto 0):=(others=>'0'); -- TODO: from memory step
        if_branch: in std_logic := '0'; -- if branch
        if_jump: in std_logic := '0';

        pc: out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
        pc_next: out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    );
end fetchStage;

architecture arch of fetchStage is
    signal pc_register: STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal pc_next_register: STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    -- signal readbuffer: std_logic_vector (bit_width-1 downto 0);

    -- component memory is
    --     generic(

    --         word_size : INTEGER := 32;

    --     );
    --     port(
    --         clock: IN STD_LOGIC;
    --         writedata: IN STD_LOGIC_VECTOR (word_size-1 DOWNTO 0);    -- WORD ADDRESSABILITY; However, only data memory can be written
    --         memwrite: IN STD_LOGIC;							-- write reqeust for data
            
    --         inst_address: IN INTEGER RANGE 0 TO inst_ram_size-1;
    --         data_address: IN INTEGER RANGE 0 TO data_ram_size-1;
        
    --         datamemread: IN STD_LOGIC;						-- read request for data
    --         instmemread: IN STD_LOGIC;						-- read request for instruction
        
    --         readdata: OUT STD_LOGIC_VECTOR (word_size-1 DOWNTO 0);	-- WORD ADDRESSABILITY
    --         waitrequest: OUT STD_LOGIC;
        
    --         memload: IN STD_LOGIC;			-- signal to load initial instructions from "program.txt"	
    --         memoutput: IN STD_LOGIC			-- signal to write output file
    --     );
    --     end component;
begin

-- dut: memory
-- port map (
--     clock=>clock,
--     instmemread=>m_read,
--     inst_address=>m_addr,
--     readdata=>readbuffer
--     -- waitrequest=>m_waitrequest,
-- );

-- change output
pc <= pc_register;
pc_next <= pc_next_register;

-- trigger when sensitive list is triggered
pc_process: process(clock,reset,pc_register,pc_next_register,stall,if_branch,if_jump)
begin
    -- updatee pc_next_register
    if (reset='1') then
        pc_next_register := 0;
    elsif (if_branch='1') then
        pc_next_register := branch_addr;
    elsif (if_jump='1') then
        pc_next_register := jump_addr;
    elsif (pc_register + 4 >= memory_size-1) then
        pc_next_register := pc_register;
    elsif (stall='1') then
        pc_next_register := pc_register;
    else
        pc_next_register := pc_register + 4;
    end if;

    -- update pc_register
    -- if want to reset
    if (reset='1') then
        pc_register <=0;
    elsif (rising_edge(clock)) then
        if if_jump = '0' and if_branch = '0' then
            pc_register <= pc_next_register;
        else
            
        end if;
    end if;

end process;

-- memory_process: process(clock, reset, pc_register,m_readdata,stall)
-- begin
--     -- TODO: get instructions from memory
--     if reset = '1' or stall = '1' then
--         -- do nothing
--         instruction <= x"ffffffff"; -- garbage output for stall to notify decode and execute stage
--     elsif rising_edge(clock) then
--         m_read <= '1';
--         m_addr <= pc_register;
--         instruction <= readbuffer;

--     end if;

-- end process;
end architecture;