library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ALU IS
	PORT(
			data1 : IN SIGNED(31 DOWNTO 0);
			op2 : IN SIGNED (31 DOWNTO 0); -- output from a 2MUX (either data2 or instruct(15 downto 0))
			ALUcontrol : IN INTEGER range 0 to 26; --sequential encoding based on page 2 of the pdf

			ALUresult : OUT SIGNED(31 DOWNTO 0);
            hi : OUT SIGNED(31 DOWNTO 0);
			lo : OUT SIGNED(31 DOWNTO 0);
			zero : OUT STD_LOGIC
       );
END ALU;

ARCHITECTURE arith OF ALU IS

Signal temp_ALUresult : signed(63 downto 0) := (others => '0'); -- prevent overflow
Signal ALUresult_buffer	: signed(31 downto 0) := (others => '0'); -- buffer for output

-- signal lo_buffer : SIGNED(31 DOWNTO 0);
-- signal hi_buffer : SIGNED(31 DOWNTO 0);
BEGIN
	ALU_unit : process(ALUcontrol, data1, op2)
	BEGIN
		CASE ALUcontrol IS
			WHEN 0 | 2 => -- add, addi
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 + op2;
				-- ALUresult_buffer <= temp_ALUresult(31 downto 0); -- keep lower 32 bits
				

			WHEN 1 => -- sub
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 - op2;
				
			WHEN 3 => -- mult
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				-- temp_ALUresult <= data1 * op2;
				-- TODO: That's probably not correct
				temp_ALUresult <= data1 * op2;	 -- NOTE: 32 bits multiplication can be divided into two parts: 16bits x 16bits	
                
			WHEN 4 => -- div
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				temp_ALUresult(31 downto 0) <= data1 / op2;
				temp_ALUresult(63 downto 32) <= data1 mod op2;
				
			WHEN 5 | 6 => -- slt, slti
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				if ( to_integer(data1) - to_integer(op2) ) < 0 then
					ALUresult_buffer <= (0 => '1', others => '0');
				else
					ALUresult_buffer <= (others => '0');
					-- should not worry about zero output here
				END if;
                
			WHEN 7 | 11 => -- and, andi
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 and op2;
                
			WHEN 8 | 12 => -- or, ori
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 or op2;
                
			WHEN 9 => -- nor
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 nor op2;
                
			WHEN 10 | 13 => -- xor, xori
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 xor op2;
                
			WHEN 14 => -- mfhi (nothing to do in execution stage)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
                
			WHEN 15 => -- mflo (nothing to do in execution stage)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
                
			WHEN 16 => -- lui (load from upper)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                -- shift_left / shift_right operation is logical iff the first oprand is unsigned
                ALUresult_buffer <= signed( shift_left(unsigned(op2), 16) );
                
			WHEN 17 => -- sll (shift left logical)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALUresult_buffer <= signed( shift_left(unsigned(data1), to_integer(op2)) );
                
			WHEN 18 => -- srl (shift right logical)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALUresult_buffer <= signed( shift_right(unsigned(data1), to_integer(op2)) );
                
			WHEN 19 => -- sra
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALUresult_buffer <= shift_right(data1, to_integer(op2));
                
			WHEN 20 => -- lw (load word)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
                
			WHEN 21 => -- sw (store word)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALUresult_buffer <= op2; -- pass the word to be stored to memeory stage
                
			WHEN 22 => -- beq (Adder computes new relative PC address(TODO), ALU determines if equal)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				-- TODO: Same as sub?
				ALUresult_buffer <= data1 - op2;
                
			WHEN 23 => -- bne
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                -- TODO: Same as sub?
				ALUresult_buffer <= data1 - op2;
                
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
				-- NO-OP or STALL
                null;
                
		END CASE;
        -- in case of stall, the following "if" block should not change "zero" output because ALU_reuslt didn't change
		-- TODO: Still problematic in the same process!
		if ALUresult_buffer = x"00000000" then
			zero <= '1';
        else
        	zero <= '0';
		END if;	
	END process;

	-- CAN't USE MULTIPLE PROCESS BLOCK TO DRIVE SAME OUTPUT!!!!

	-- multiplication_buffer_process : process(multiplication_buffer, ALUcontrol)
	-- begin
	-- 	if ALUcontrol = 3 then
	-- 		lo_buffer <= multiplication_buffer(31 downto 0);
	-- 		hi_buffer <= multiplication_buffer(63 downto 32);
	-- 	end if;
	-- end process;

	-- signal connect to output
	ALUresult <= ALUresult_buffer;

	lo <= temp_ALUresult(31 downto 0);
	hi <= temp_ALUresult(63 downto 32);
END arith;


