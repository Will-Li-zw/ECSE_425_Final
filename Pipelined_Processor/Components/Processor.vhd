--This processor entity will connect five stages together 
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_textio.all;			 -- package for io to write std_logic_vector

library std;
USE std.textio.all;						 -- package for io keywords: file_open()

entity Processor is
-- TODO: haven't finished
	generic(
		clock_period : time := 1 ns;
		word_size : INTEGER := 32
	);
	port (
		clock       : in std_logic;
        instruction : in std_logic_vector(wordsize-1 downto 0);
        read_data   : in std_logic_vector(wordsize-1 downto 0);
        
        pc          : out integer;
        data_addr   : out integer;
        write_req   : out std_logic;
        instread_req : out std_logic;
        dataread_req : out std_logic;
        write_data  : out std_logic_vector(wordsize-1 downto 0)
	);
end Processor;

architecture behavior of Processor is 
	-- components declaration
	component fetch is 
	port(
		--
	);
	end component;

	component decode is 
	port(
		--
	);
	end component;

	component execute is 
	port(
		--
	);
	end component;

	component memory is 
	port(
		--
	);
	end component;

	component writeback is 
	port(
		--
	);
	end component;

begin
	-- 连连看:

end behavior;