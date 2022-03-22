library IEEE;
use IEEE.std_logic_1164.all;

ENTITY ALU IS
	PORT(
			data0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			data1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			ALUcontrol : IN STD_LOGIC_VECTOR (3 DOWNTO 0); --4 bits? Or 3? I've seen both
			ALUresult : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			zero : OUT STD_LOGIC
       );
END ALU;

ARCHITECTURE arith OF ALU IS
BEGIN
	--TODO
END arith;
