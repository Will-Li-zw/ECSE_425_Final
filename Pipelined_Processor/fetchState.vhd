library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetchStage is
    generic(
        menory_size: integer := 8192; --data memory size is 8192 lines
        bit_width: integer := 32
    );

    port(
        clock: in std_logic; --required
        reset: in std_logic; --required
        stall: in std_logic; --required
        pc: out integer; --required
        instruction: out std_logic; --required

        m_addr: out integer range 0 to menory_size-1;
        m_read: out std_logic;
        m_readdata: in std_logic_vector (bit_width-1 downto 0);
        -- write is not needed in fetch stage
    );
end fetchStage;

