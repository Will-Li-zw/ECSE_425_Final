library ieee; -- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- needed if you are using unsigned rotate operations

-- TOP LEVEL ENTITY FOR EXECUTE STAGE
entity execute_stage is
	port(
        --------------
        -- *inputs* --
        --------------
        clk : in std_logic;
		read_data_1 : in signed(31 downto 0);       -- register data 1
        read_data_2 : in signed(31 downto 0);       -- register data 2
        ALUcontrol : in integer range 0 to 27;      -- interpreted op code from DECODE->EXE
        extended_lower_15_bits : in signed(31 downto 0); -- lower 16 bits (sign/zero extended to 32) passed in
        pc_plus_4 : in std_logic_vector(31 downto 0);   -- carried pc_next value from FET->DEC->EXE->...
        
        -- reg address
        reg_sel : in std_logic; -- if 0, then pass on rd (R), else, pass on rt (I)
        rt : in std_logic_vector(4 downto 0); 
        rd : in std_logic_vector(4 downto 0);
        
        -- control inputs:
		twomux_sel : in std_logic; -- choose read data 2 or immediate


        -- TODO: what are the meaning of these signals
		reg_file_enable_in : in std_logic;
        mem_to_reg_flag_in : in std_logic;
        mem_write_request_in : in std_logic;
        mem_read_request_in : in std_logic;

        -- forwarding inputs:
        mem_exe_reg_data    : in signed(31 downto 0);                       -- account for MEM->EXE forwarding
        mem_exe_reg_addr    : in std_logic_vector(4 downto 0); 
        forwarded_exe_exe_reg_data    : in signed(31 downto 0);             -- account for EXE->EXE forwarding
        forwarded_exe_exe_reg_addr    : in std_logic_vector(4 downto 0); 
        
       
        
        ---------------
        -- *outputs* --
        ---------------
        -- forwarding outputs:
        forwarding_exe_exe_reg_data    : out signed(31 downto 0);           -- output forwarding to next CC EXE
        forwarding_exe_exe_reg_addr    : out std_logic_vector(4 downto 0); 

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

        -- branching output signals
        if_branch : out std_logic;
        
        -- control outputs (TODO: may not be complete)
        reg_file_enable_out : out std_logic;
        mem_to_reg_flag_out : out std_logic;
        mem_write_request_out : out std_logic;
        mem_read_request_out : out std_logic
	);
end execute_stage;

ARCHITECTURE exe OF execute_stage IS

SIGNAL muxout: signed(31 downto 0);

-- output intermediate buffer registers to make the circuit synchronous
SIGNAL reg_address_buffer : std_logic_vector(4 downto 0);
SIGNAL read_data_2_out_buffer : signed(31 downto 0);
SIGNAL pc_plus_4_out_buffer : std_logic_vector(31 downto 0);
SIGNAL Addresult_buffer : signed(31 downto 0);
SIGNAL zero_buffer : std_logic;
SIGNAL ALUresult_buffer : signed(31 downto 0);
SIGNAL hi_buffer : signed(31 downto 0);
SIGNAL lo_buffer : signed(31 downto 0);

SIGNAL reg_file_enable_out_buffer : std_logic;
SIGNAL mem_to_reg_flag_out_buffer : std_logic;
SIGNAL mem_write_request_out_buffer : std_logic;
SIGNAL mem_read_request_out_buffer : std_logic;

-- for forwarding logic: option 0 means no forwarding, 1 means forward father's result, 2 means forward grandpa's result
SIGNAL op1_option : integer range 0 to 3 := 0;
SIGNAL op2_option : integer range 0 to 3 := 0;
SIGNAL grandpa_rd : std_logic_vector(4 downto 0) := (others => 'U'); -- previous previous instruction's destination
SIGNAL father_rd : std_logic_vector(4 downto 0) := (others => 'U'); -- previous instruction's destination
SIGNAL grandpa_result : std_logic_vector(31 downto 0) := (others => 'U'); -- previous previous instruction's ALU result
SIGNAL father_result : std_logic_vector(31 downto 0) := (others => 'U'); -- previous instruction's ALU result

COMPONENT THREEMUX IS -- for forward logic
	port (
			sel : IN integer range 0 to 3;
			input0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            input2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END COMPONENT;

COMPONENT TWOMUX IS
	port (
			sel : IN STD_LOGIC;
			input0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END COMPONENT;

COMPONENT ALU IS
	port (
			data1 : IN SIGNED(31 DOWNTO 0);
			op2 : IN SIGNED (31 DOWNTO 0); -- output from a 2MUX (either data2 or instruct(15 downto 0))
			ALUcontrol : IN INTEGER range 0 to 26; --sequential encoding based on page 2 of the pdf
            extended_imm : in SIGNED(31 downto 0); -- for shift instruction, lower 16 bits (sign/zero extended to 32)

			ALUresult : OUT SIGNED(31 DOWNTO 0);
            hi : OUT SIGNED(31 DOWNTO 0);
			lo : OUT SIGNED(31 DOWNTO 0);
			zero : OUT STD_LOGIC
    );
END COMPONENT;

COMPONENT ADD IS
	port (
			pc_plus_4 : IN SIGNED(31 DOWNTO 0); -- value of (PC + 4) passed in
            extended_lower_15_bits : IN SIGNED(31 DOWNTO 0); -- lower 16 bits (sign/zero extended to 32) passed in
            
			Addresult : OUT SIGNED(31 DOWNTO 0);
            pc_plus_4_out : OUT SIGNED(31 DOWNTO 0)
    );
END COMPONENT;

BEGIN

    -- TODO: forward muxs
	-- cmpnt_fwd1_threemux: THREEMUX port map( -- for choosing first ALU operand
	-- 	sel             => twomux_sel,
    --     input0          => std_logic_vector(read_data_2),        -- to match type
    --     input1          => std_logic_vector(extended_lower_15_bits),
    --     signed(output)  => muxout
	-- );
    
	-- cmpnt_fwd2_threemux: THREEMUX port map( -- for choosing second ALU operand
	-- 	sel             => twomux_sel,
    --     input0          => std_logic_vector(read_data_2),        -- to match type
    --     input1          => std_logic_vector(extended_lower_15_bits),
    --     signed(output)  => muxout
	-- );

	cmpnt_twomux: TWOMUX port map(
		sel             => twomux_sel,
        input0          => std_logic_vector(read_data_2),        -- to match type
        input1          => std_logic_vector(extended_lower_15_bits),
        signed(output)  => muxout
	);

	cmpnt_alu: ALU port map(
		data1 => read_data_1,      -- TODO: For implementing forwarding, we need to change the port mapped data
        op2 => muxout,
        ALUcontrol => ALUcontrol,
        extended_imm => extended_lower_15_bits,
        ALUresult => ALUresult_buffer,
        hi => hi_buffer,
        lo => lo_buffer,
        zero => zero_buffer
	);

	cmpnt_add: ADD port map(
		pc_plus_4                       => signed(pc_plus_4),
        extended_lower_15_bits          => extended_lower_15_bits,
        Addresult                       => Addresult_buffer,
        std_logic_vector(pc_plus_4_out) => pc_plus_4_out_buffer
	);

    Branch: PROCESS(ALUcontrol, read_data_1, read_data_2, clk) -- JUMP is done in decode stage
    BEGIN
        if rising_edge(clk) then
            CASE ALUcontrol IS
                WHEN 22 => -- beq
                    IF read_data_1 = read_data_2 THEN
                        if_branch <= '1';
                    ELSE if_branch <= '0';
                    END IF;
                WHEN 23 => -- bne
                    IF read_data_1 = read_data_2 THEN
                        if_branch <= '1';
                    ELSE if_branch <= '0';
                    END IF;
                WHEN Others =>
                    if_branch <= '0';
            END CASE;
        end if;
    END PROCESS;

    forwarding: PROCESS(clk)
    BEGIN
    	IF (ALUcontrol /= 24) and (ALUcontrol /= 26) THEN -- possibe forwarding
        	IF reg_sel = '0' THEN -- R type instruction
                null; -- TODO
            ELSE -- I type instruction
            	null; -- TODO
            END IF;
        END IF;
    END PROCESS;
	
	PROCESS(clk) 
	BEGIN
		IF rising_edge(CLK) THEN
			reg_address     <= reg_address_buffer;
            read_data_2_out <= read_data_2_out_buffer;
            pc_plus_4_out   <= pc_plus_4_out_buffer;
            Addresult       <= Addresult_buffer;
            zero            <= zero_buffer;
            ALUresult       <= ALUresult_buffer;
            hi              <= hi_buffer;
            lo              <= lo_buffer;
            reg_file_enable_out     <= reg_file_enable_out_buffer;
            mem_to_reg_flag_out     <= mem_to_reg_flag_out_buffer;
            mem_write_request_out   <= mem_write_request_out_buffer;
            mem_read_request_out   <= mem_read_request_out_buffer;
            
		END IF;
	END process; -- end process
    
    -- below are combinatorial, clock delay achieved in process block
    -- op2 <= muxout;              -- TODO: op2 is not an output signal nor intermediate signal

    -- TODO: Zichen: I changed the "reg_file_enable_out_buffer" to "reg_address_buffer"...
    -- TODO? why we are using twomux_sel here?????
	WITH reg_sel select reg_address_buffer <=        
			rd WHEN '1', -- R type instruction, use rd in WB
			rt WHEN '0', -- I type instruction, use rt in MEM
			(others => 'X') WHEN others;
            
    read_data_2_out_buffer <= read_data_2;
	reg_file_enable_out_buffer <= reg_file_enable_in;
	mem_to_reg_flag_out_buffer <= mem_to_reg_flag_in;
    mem_write_request_out_buffer <= mem_write_request_in;
    mem_read_request_out_buffer <= mem_read_request_in;
    
END exe; -- end architecture
