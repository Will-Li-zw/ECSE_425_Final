library IEEE;
use IEEE.std_logic_1164.all;

ENTITY THREEMUX IS
	PORT(
			sel : IN integer range 0 to 3;
			input0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
       );
END THREEMUX;

ARCHITECTURE mux3 OF THREEMUX IS
BEGIN
	WITH sel select output <=
			input0 WHEN 0,
			input1 WHEN 1,
			input2 WHEN 2,
			(others => 'X') WHEN others;
END mux3;
