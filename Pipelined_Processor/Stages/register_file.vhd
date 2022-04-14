library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_file is
    port (
        clk_rf : in std_logic;
        reset : in std_logic;

        r_reg1 : in std_logic_vector(4 downto 0);
        r_reg2 : in std_logic_vector(4 downto 0);
        w_reg : in std_logic_vector(4 downto 0);
        w_enable : in std_logic;
        w_data : in std_logic_vector(31 downto 0);

        r_data1 : out std_logic_vector(31 downto 0);
        r_data2 : out std_logic_vector(31 downto 0)
    );
end entity;

architecture arch of register_file is
    -- initialize the register array
    type registers is array (0 to 31) of std_logic_vector (31 downto 0);
    signal r: registers := (others=>(others=>'0'));

    begin
        -- output data in two registers 
        r_data1 <= r(to_integer(unsigned(r_reg1)));
        r_data2 <= r(to_integer(unsigned(r_reg2)));

        process(clk_rf, reset, w_enable)
            begin
            -- if there is a rising edge    
            if (clk_rf='1') then
                if reset = '1' then -- check the reset signal
                    r <= (others=>(others=>'0'));
                else
                    if w_enable = '1' then
                        r(to_integer(unsigned(w_reg))) <= w_data;
                    end if;
                end if;
            end if;
        end process;

        -- r(to_integer(unsigned(w_reg))) <= w_data when w_enable = '1';
end arch;
