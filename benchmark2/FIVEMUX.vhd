library IEEE;
use IEEE.std_logic_1164.all;

ENTITY FIVEMUX IS
	PORT(
			sel : IN integer range 0 to 5;
			input0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			input2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            input3 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            input4 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			output : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
       );
END FIVEMUX;

ARCHITECTURE mux5 OF FIVEMUX IS
BEGIN
	WITH sel select output <=
			input0 WHEN 0,
			input1 WHEN 1,
			input2 WHEN 2,
            input3 WHEN 3,
            input4 WHEN 4,
			(others => 'X') WHEN others;
END mux5;
