LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;			 -- package for io to write std_logic_vector

library std;
USE std.textio.all;						 -- package for io keywords: file_open()

entity register_file is
    generic(
        -- output file path
        regoutput_filepath : string := "register_file.txt"
    );
    port (
        clk_rf : in std_logic;
        reset : in std_logic;

        r_reg1 : in std_logic_vector(4 downto 0);
        r_reg2 : in std_logic_vector(4 downto 0);
        w_reg : in std_logic_vector(4 downto 0);
        w_enable : in std_logic;
        w_data : in std_logic_vector(31 downto 0);

        -- output process:
        regoutput: in std_logic;

        r_data1 : out std_logic_vector(31 downto 0);
        r_data2 : out std_logic_vector(31 downto 0)
    );
end entity;

architecture arch of register_file is
    -- initialize the register array
    type registers is array (0 to 31) of std_logic_vector (31 downto 0);
    signal r: registers := (others=>(others=>'0'));

    -- write the data memory to the file
	procedure output_registers_to_file (regs : registers) is
		file     	f  : text;
		variable aline : line;
		variable i: integer range 0 to 35 := 0;	-- loop counter
	begin
		file_open(f, regoutput_filepath, write_mode);
		L1: while i < 32 loop           -- index from 0 to 31
			write(aline, regs(i));		-- pass content of aline
			writeline(f, aline);		-- put line into the output file
			i := i+1;					-- update counter by 4(a word offset)
		end loop;
		file_close(f);
	end output_registers_to_file;

    begin
        -- write registers output
        write_process: PROCESS(regoutput, clk_rf)
        BEGIN
            if rising_edge(clk_rf) then
                IF (regoutput = '1') THEN
                    output_registers_to_file(r);
                END IF;
            end if;
        END PROCESS;

        -- output data in two registers 
        r_data1 <= r(to_integer(unsigned(r_reg1)));
        r_data2 <= r(to_integer(unsigned(r_reg2)));

        process(clk_rf, reset, w_enable, w_data)
            begin
            -- async reset
            if reset = '1' then -- check the reset signal
                r <= (others=>(others=>'0'));
            end if;
    
            if clk_rf = '1' then                -- if clock high,
                if w_enable = '1' then
                    r(to_integer(unsigned(w_reg))) <= w_data;
                end if;
            end if;
        end process;

end arch;
