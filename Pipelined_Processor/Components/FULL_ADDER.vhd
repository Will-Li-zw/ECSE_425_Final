library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity full_adder is
    port(
        X   : in    std_logic;
        Y   : in    std_logic;
        CIN : in    std_logic;
        COUT    : out   std_logic;
        R   : out   std_logic
    );
end full_adder;

architecture Behavioral of full_adder is

signal G,P : std_logic;

begin
    G <= X and Y;
    P <= X xor Y;
    COUT <= G or ( P and CIN );
    R <= P xor CIN;    
end Behavioral;