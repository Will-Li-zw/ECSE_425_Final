library IEEE;
use IEEE.std_logic_1164.all;

ENTITY TWOMUX IS
	PORT(
			sel : IN STD_LOGIC;
			input0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
       );
END TWOMUX;

ARCHITECTURE mux2 OF TWOMUX IS
BEGIN
	WITH sel select output <=
			input0 WHEN '0',
			input1 WHEN '1',
			(others => 'X') WHEN others;
END mux2;
