library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ALU IS
	PORT(
			data1 : IN SIGNED(31 DOWNTO 0);
			op2 : IN SIGNED (31 DOWNTO 0); -- output from a 2MUX (either data2 or extended instruct(15 downto 0))
			ALUcontrol : IN INTEGER range 0 to 27; -- sequential encoding based on page 2 of the pdf
			extended_imm : in SIGNED(31 downto 0); -- for shift instructions' shamt, lower 16 bits (sign/zero extended to 32)

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
				if data1+op2 = 0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
				-- ALUresult_buffer <= temp_ALUresult(31 downto 0); -- keep lower 32 bits
				

			WHEN 1 => -- sub
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 - op2;
				if data1-op2 = 0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
				
			WHEN 3 => -- mult
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				temp_ALUresult <= data1 * op2;	 
				if data1=0 or op2= 0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
                
			WHEN 4 => -- div
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				temp_ALUresult(31 downto 0) <= data1 / op2;
				temp_ALUresult(63 downto 32) <= data1 mod op2;
				if data1=0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
				
			WHEN 5 | 6 => -- slt, slti
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				if ( to_integer(data1) - to_integer(op2) ) < 0 then
					ALUresult_buffer <= (0 => '1', others => '0');
					zero <= '0';
				else
					ALUresult_buffer <= (others => '0');
					zero <= '1';
					-- should not worry about zero output here
				END if;
                
			WHEN 7 | 11 => -- and, andi
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 and op2;
				if (data1 and op2)=0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
                
			WHEN 8 | 12 => -- or, ori
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 or op2;
				if (data1 or op2)=0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
                
			WHEN 9 => -- nor
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 nor op2;
				if (data1 nor op2)=0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
                
			WHEN 10 | 13 => -- xor, xori
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= data1 xor op2;
				if (data1 xor op2)=0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
                
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
				if (shift_left(unsigned(op2), 16))=0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
                
			WHEN 17 => -- sll (shift left logical)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALUresult_buffer <= signed( shift_left(unsigned(op2), to_integer(extended_imm(10 downto 6))) );
                if (shift_left(unsigned(op2), to_integer(extended_imm(10 downto 6))))=0 then
					zero <= '1';
				else
					zero <= '0';
				end if;

			WHEN 18 => -- srl (shift right logical)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALUresult_buffer <= signed( shift_right(unsigned(op2), to_integer(extended_imm(10 downto 6))) );
                if shift_right(unsigned(op2), to_integer(extended_imm(10 downto 6)))=0 then
					zero <= '1';
				else
					zero <= '0';
				end if;

			WHEN 19 => -- sra
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALUresult_buffer <= shift_right(op2, to_integer(extended_imm(10 downto 6)));
				if shift_right(op2, to_integer(extended_imm(10 downto 6))) = 0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
                
			WHEN 20 => -- lw (load word)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				
                null;
                
			WHEN 21 => -- sw (store word)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                ALUresult_buffer <= op2; -- pass the word to be stored to memeory stage
				if op2 = 0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
                
			WHEN 22 => -- beq (ALU computes new relative PC address, execute_stage.vhd determines if equal)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= op2; -- op2 is branch_address, this value to be added to (PC + 4) in execute_stage.vhd
				if op2 = 0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
                
			WHEN 23 => -- bne (ALU computes new relative PC address, execute_stage.vhd determines if equal)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
				ALUresult_buffer <= op2; -- op2 is branch_address, this value to be added to (PC + 4) in execute_stage.vhd
				if op2 = 0 then
					zero <= '1';
				else
					zero <= '0';
				end if;
                
			WHEN 24 => -- j (taken cared in decode stage)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
                
			WHEN 25 => -- jr (taken cared in decode stage)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
                
			WHEN 26 => -- jal (taken cared in decode stage)
				report "The value of 'ALUcontrol' is " & integer'image(ALUcontrol);
                null;
                
			WHEN others =>
				-- NO-OP or STALL
                null;
                
		END CASE;
        -- in case of stall, the following "if" block should not change "zero" output because ALU_reuslt didn't change
		-- TODO: Still problematic in the same process!
		-- if ALUresult_buffer = x"00000000" then
		-- 	zero <= '1';
        -- else
        -- 	zero <= '0';
		-- END if;	
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


