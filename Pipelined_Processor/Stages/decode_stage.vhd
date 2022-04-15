library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decode_stage is
    generic(
        reg_adrsize : INTEGER := 32;
        ctrl_size : INTEGER := 8
    );
    port (
        clk : in std_logic;
        reset : in std_logic;

        pc_in : in std_logic_vector(31 downto 0);
        pc_out : out std_logic_vector(31 downto 0);
        instruction_in : in std_logic_vector (31 downto 0);

        w_data : in std_logic_vector(31 downto 0);
        w_addr : in std_logic_vector(4 downto 0);
        w_enable : in std_logic;

        mem_reg : in std_logic_vector(4 downto 0);

        -- output request signal:
        reg_output: in std_logic;
        

        rs_addr : out std_logic_vector(4 downto 0);
        rt_addr : out std_logic_vector(4 downto 0);
        rd_addr : out std_logic_vector(4 downto 0);             -- destination register addr
        rs_data : out std_logic_vector(reg_adrsize-1 downto 0); -- contents of rs
        rt_data : out std_logic_vector(reg_adrsize-1 downto 0); -- contents of rt
        imm_32 : out std_logic_vector(reg_adrsize-1 downto 0);  -- sign extended immediate value
        jump_addr : out std_logic_vector(reg_adrsize-1 downto 0);

        -------- CTRL signals --------
        -- whether to stall the fetch
        stall_out : out std_logic;
        -- Register Write
        reg_write: out std_logic; -- determine if a result needs to be written to a register
        reg_dst: out std_logic; -- select the dst reg as either rs(R-type instruction) or rt(I-type instruction)
        mem_to_reg: out std_logic;
        -- PC update
        jump: out std_logic;
        branch: out std_logic;
        -- Memory Access
        mem_read: out std_logic;
        mem_write: out std_logic;
        -- Source Operand Fetch
        alu_src: out std_logic; -- select the second ALU input from either rt or sign-extended immediate
        -- ALU Operation
        alu_op: out integer range 0 to 27 -- ALU code for EXE
    );
end entity;

architecture Behavioral of decode_stage is
    signal imm_16 : std_logic_vector(15 downto 0);
    signal jump_addr_s : std_logic_vector(25 downto 0);
    signal rs_s : std_logic_vector(4 downto 0);
    signal rt_s : std_logic_vector(4 downto 0);
    signal ctrl_sigs : std_logic_vector(ctrl_size-1 downto 0);
    signal cur_instruction : std_logic_vector(reg_adrsize-1 downto 0);
    signal last_instruction : std_logic_vector(reg_adrsize-1 downto 0);
    signal last_stall : std_logic := '0';
begin
    rf : entity work.register_file
    port map(
        -- input signals
        clk_rf => clk,
        reset => reset,

        r_reg1 => rs_s,
        r_reg2 => rt_s,
        w_reg => w_addr,
        w_enable => w_enable,
        w_data => w_data,

        regoutput   => reg_output,

        -- output signals
        r_data1 => rs_data,
        r_data2 => rt_data
    );

    decode_stage : process(clk)
    variable opcode : std_logic_vector(5 downto 0);
    variable rs : std_logic_vector(4 downto 0);
    variable rt : std_logic_vector(4 downto 0);
    variable rd : std_logic_vector(4 downto 0);
    variable shamt : std_logic_vector(4 downto 0);
    variable funct : std_logic_vector(5 downto 0);
    begin
        if rising_edge(clk) then
            if last_stall = '1' then
                -- cur_instruction <= last_instruction;
                last_stall <= '0';
                stall_out <= '0';
                opcode := last_instruction(31 downto 26);
                rs := last_instruction(25 downto 21);
                rt := last_instruction(20 downto 16);
                rd := last_instruction(15 downto 11);
                shamt := last_instruction(10 downto 6);
                funct := last_instruction(5 downto 0);
                
                imm_16 <= last_instruction(15 downto 0);  -- immediate value
                jump_addr_s <= last_instruction(25 downto 0);
            else
                -- cur_instruction <= instruction_in;
                opcode := instruction_in(31 downto 26);
                rs := instruction_in(25 downto 21);
                rt := instruction_in(20 downto 16);
                rd := instruction_in(15 downto 11);
                shamt := instruction_in(10 downto 6);
                funct := instruction_in(5 downto 0);

                imm_16 <= instruction_in(15 downto 0);  -- immediate value
                jump_addr_s <= instruction_in(25 downto 0);
            end if;

            rs_s <= rs;
            rt_s <= rt;
            rd_addr <= rd;
            rs_addr <= rs;
            rt_addr <= rt;
            pc_out <= pc_in;

            -------------------- R-instruction--------------------
            if opcode = "000000" then   
                -- hazard detection
                -- if depency detected ==> stall_out = 1, last_stall = 1
                if (mem_reg /= "UUUUU" or rs_s /= "UUUUU" or rt_s /= "UUUUU") and (mem_reg = rs_s or mem_reg = rt_s) then
                    stall_out <= '1';
                    last_stall <= '1';
                    funct := "111111";
                else -- otherwise, deassert the stall signal
                    stall_out <= '0';
                    last_stall <= '0';
                end if;
                case(funct) is 
                    when "100000" => alu_op <= 0;         -- 0. add
                    when "100010" => alu_op <= 1;         -- 1. substract
                    when "011000" => alu_op <= 3;         -- 3. mult
                    when "011010" => alu_op <= 4;         -- 4. div
                    when "101010" => alu_op <= 5;         -- 5. slt
                    when "100100" => alu_op <= 7;         -- 7. and
                    when "100101" => alu_op <= 8;         -- 8. or
                    when "100111" => alu_op <= 9;         -- 9. nor
                    when "100110" => alu_op <= 10;        -- 10. xor
                    when "010000" => alu_op <= 14;        -- 14. mfhi
                    when "010010" => alu_op <= 15;        -- 15. mflo
                    when "000000" => alu_op <= 17;        -- 17. sll
                    when "000010" => alu_op <= 18;        -- 18. srl
                    when "000011" => alu_op <= 19;        -- 19. sra
                    when "001000" => alu_op <= 25;        -- 25. jr
                    when others => alu_op <= 27;
                end case;
                ctrl_sigs <= "11000001";
                
            -------------------- J-instruction--------------------
            elsif opcode = "000010" then  -- 24. j
                alu_op <= 24;
                jump_addr <= std_logic_vector(resize(unsigned(jump_addr_s), jump_addr'length));
                ctrl_sigs <= "0U000100";      
            elsif opcode = "000011" then  -- 26. jal
                alu_op <= 26;   
                jump_addr <= std_logic_vector(resize(unsigned(jump_addr_s), jump_addr'length));
                ctrl_sigs <= "0U000100";
                
            -------------------- Null-instruction ----------------
            -- Note: added by Zichen, to accomodate when instruction is undefined
            elsif opcode = "UUUUUU" then        -- when instruction is null
                alu_op <= 27;
                stall_out <= '0';               -- release stall
                last_stall <= '0';  
                -- ctrl_sigs <= "UUUUUUUU";        -- control signal to U

            -------------------- I-instruction--------------------
            else
                if (mem_reg /= "UUUUU" or rs_s /= "UUUUU") and (mem_reg = rs_s) then  -- if dependency detected
                    stall_out <= '1';
                    last_stall <= '1';
                else 
                    stall_out <= '0';
                    last_stall <= '0';
                end if;

                if opcode = "001000" then  -- 2. addi
                    alu_op <= 2;
                    
                    ctrl_sigs <= "10000001";   
                elsif opcode = "001010" then  -- 6. slti
                    alu_op <= 6;
                    -- imm_32 <= std_logic_vector(resize(signed(imm_16), imm_32'length));
                    ctrl_sigs <= "10000001";
                elsif opcode = "001100" then  -- 11. andi
                    alu_op <= 11;
                    -- imm_32 <= std_logic_vector(resize(signed(imm_16), imm_32'length));
                    ctrl_sigs <= "10000001";  
                elsif opcode = "001101" then  -- 12. ori
                    alu_op <= 12;
                    -- imm_32 <= std_logic_vector(resize(signed(imm_16), imm_32'length));
                    ctrl_sigs <= "10000001";
                elsif opcode = "001110" then  -- 13. xori
                    alu_op <= 13;
                    -- imm_32 <= std_logic_vector(resize(signed(imm_16), imm_32'length));
                    ctrl_sigs <= "10000001";  
                elsif opcode = "001111" then  -- 16. lui
                    alu_op <= 16;
                    -- imm_32 <= std_logic_vector(resize(signed(imm_16), imm_32'length));
                    ctrl_sigs <= "10000001"; 
                elsif opcode = "100011" then  -- 20. lw
                    alu_op <= 20;   
                    ctrl_sigs <= "10000101";
                elsif opcode = "101011" then  -- 21. sw
                    alu_op <= 21;    
                    ctrl_sigs <= "00000011";
                elsif opcode = "000100" then  -- 22. beq
                    alu_op <= 22;
                    ctrl_sigs <= "00001000";
                elsif opcode = "000101" then  -- 23. bne
                    alu_op <= 23;
                    ctrl_sigs <= "00001000";
                else 
                    ctrl_sigs <= "00000000";
                end if;  
            end if;


            last_instruction <= instruction_in;     -- each clock cycle update the last_instruction register to the latest one
        end if;
    end process;

    -- always output the immediatevalue; circuit are taken care by control signals
    imm_32 <= std_logic_vector(resize(signed(imm_16), imm_32'length));

    -- Control signal output
    reg_write <= ctrl_sigs(7); -- determine if a result needs to be written to a register
    reg_dst <= ctrl_sigs(6); -- select the dst reg as either rd(R-type instruction) or rt(I-type instruction)
    mem_to_reg <= ctrl_sigs(5); -- if select ALUresult or data memory to WB
    jump <= ctrl_sigs(4);       -- if jump
    branch <= ctrl_sigs(3);     -- if this is a branch instruction
    mem_read <= ctrl_sigs(2);   -- want to read memory: LD
    mem_write <= ctrl_sigs(1);  -- want to write memory: ST
    alu_src <= ctrl_sigs(0); -- select the second ALU input from either rt or sign-extended immediate
end Behavioral;