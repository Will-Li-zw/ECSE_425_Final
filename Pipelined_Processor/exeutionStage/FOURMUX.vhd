library IEEE;
use IEEE.std_logic_1164.all;

ENTITY FOURMUX IS
	PORT(
			sel : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			input0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input3 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
END FOURMUX;

ARCHITECTURE mux4 OF FOURMUX IS
BEGIN
	WITH sel select output <=
			input0 WHEN "00",
			input1 WHEN "01",
			input2 WHEN "10",
			input3 WHEN "11",
			(others => 'X') WHEN others;
END mux4;
