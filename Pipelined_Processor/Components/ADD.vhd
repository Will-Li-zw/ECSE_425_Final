library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ADD IS
	PORT(
			pc_plus_4 : IN SIGNED(31 DOWNTO 0); -- value of (PC + 4) passed in
            extended_lower_15_bits : IN SIGNED(31 DOWNTO 0); -- lower 16 bits (sign/zero extended to 32) passed in
            
			Addresult : OUT SIGNED(31 DOWNTO 0);
            pc_plus_4_out : OUT SIGNED(31 DOWNTO 0)
       );
END ADD;

ARCHITECTURE comb OF ADD IS
BEGIN
	Addresult <= pc_plus_4 + shift_left(extended_lower_15_bits, 2); -- shift left 2
    pc_plus_4_out <= pc_plus_4;
END comb;
