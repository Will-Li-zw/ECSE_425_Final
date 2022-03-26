library IEEE;
use IEEE.std_logic_1164.all;

ENTITY ALU IS
	PORT(
			data1 : IN SIGNED(31 DOWNTO 0);
			op2 : IN SIGNED (31 DOWNTO 0); -- output from a 2MUX (either data2 or instruct(15 downto 0))
			ALUcontrol : IN INTEGER range 0 to 26; --sequential encoding based on page 2 of the pdf
			ALUresult : OUT SIGNED(31 DOWNTO 0);
			zero : OUT STD_LOGIC
       );
END ALU;

ARCHITECTURE arith OF ALU IS

Signal temp_ALUresult : signed(63 downto 0); -- prevent overflow

BEGIN
	process 
	BEGIN
		CASE ALUcontrol IS
			WHEN 0 | 2 => -- add, addi
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				temp_ALUresult <= to_signed(signed(data1)) + to_integer(signed(op2));
				ALU_result <= temp_ALUresult(31 downto 0); -- keep lower 32 bits
				
			WHEN 1 => -- sub
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				temp_ALUresult <= to_integer(signed(data1)) - to_integer(signed(op2));
				ALU_result <= temp_ALUresult(31 downto 0);
				
			WHEN 3 => -- mult
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				temp_ALUresult <= to_integer(signed(data1)) * to_integer(signed(op2));
				ALU_result <= temp_ALUresult(31 downto 0);
                
			WHEN 4 => -- div
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				temp_ALUresult <= to_integer(signed(data1)) / to_integer(signed(op2));
				ALU_result <= temp_ALUresult(31 downto 0);
				
			WHEN 5 | 6 => -- slt, slti
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				if (to_integer(signed(data1)) - to_integer(signed(op2))) < 0 then
					ALU_result <= to_signed(0 => '1', others => '0');
				else
					ALU_result <= to_signed(0 => '0', others => '0');
					-- should not worry about zero output here
				END if;
                
			WHEN 7 | 11 => -- and, andi
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALU_result <= to_signed(std_logic_vector(data1) and std_logic_vector(op2));
                
			WHEN 8 | 12 => -- or, ori
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALU_result <= to_signed(std_logic_vector(data1) or std_logic_vector(op2));
                
			WHEN 9 => -- nor
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALU_result <= to_signed(std_logic_vector(data1) nor std_logic_vector(op2));
                
			WHEN 10 | 13 => -- xor, xori
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALU_result <= to_signed(std_logic_vector(data1) xor std_logic_vector(op2));
                
			WHEN 14 => -- mfhi (nothing to do in execution stage)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
                
			WHEN 15 => -- mflo (nothing to do in execution stage)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
                
			WHEN 16 => -- lui (load from upper)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                -- shift_left / shift_right operation is logical iff the first oprand is unsigned
                ALU_result <= shift_left(to_unsigned(op2), 16);
                
			WHEN 17 => -- sll (shift left logical)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALU_result <= shift_left(to_unsigned(data1), to_integer(op2));
                
			WHEN 18 => -- srl
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALU_result <= shift_right(to_unsigned(data1), to_integer(op2));
			WHEN 19 => -- sra
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALU_result <= shift_right(data1, to_integer(op2));
			WHEN 20 => -- lw (load word)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
			WHEN 21 => -- sw (store word)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALU_result <= op2; -- pass the word to be stored to memeory stage
			WHEN 22 => -- beq (Adder computes new relative PC address(TODO), ALU determines if equal)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				-- TODO: Same as sub?
				temp_ALUresult <= to_integer(signed(data1)) - to_integer(signed(op2));
				ALU_result <= temp_ALUresult(31 downto 0);
			WHEN 23 => -- bne
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                -- TODO: Same as sub?
				temp_ALUresult <= to_integer(signed(data1)) - to_integer(signed(op2));
				ALU_result <= temp_ALUresult(31 downto 0);
			WHEN 24 => -- j (taken cared in decode)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
			WHEN 25 => -- jr (taken cared in decode)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
			WHEN 26 => -- jal (taken cared in decode)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
			WHEN others =>
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol) & "(out of range)";
                null;
		END CASE;
		if ALU_result = (others => '0') then
			zero <= '1';
        else
        	zero <= '0'
		END if;
	END process;
END arith;

