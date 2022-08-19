library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all ;
library work;
use work.airthmetic.all;
entity alu is
	generic(data_size: integer := 16);
	port(
		a, b: in std_logic_vector(data_size-1 downto 0);
		output: out std_logic_vector(data_size-1 downto 0);
		cin: in std_logic;
		sel: in std_logic_vector(1 downto 0);
		CY,  Z: out std_logic);
end entity;

architecture logic of alu is
	signal temp: std_logic_vector(data_size-1 downto 0);
	signal add_o: std_logic_vector(data_size-1 downto 0);
	signal C: std_logic;
	signal compare, is_zero: std_logic;
begin
	
	ADD0: adder generic map(data_size)
		port map(x => a, y => b,cin => cin, sum => add_o, Cout => C);
			
	CY <= C;
	
	
	process(a,b,sel,add_o)
	begin
		if (sel(1) = '1') then
			temp <= add_o;
		else
			temp <= a nand b;
		end if;
	end process;
	
	compare <= '1' when (a = b) else '0';
	is_zero <= '1' when (to_integer(unsigned(temp)) = 0) else '0';
	Z <= is_zero when (sel(0) = '0') else compare;
	output <= temp;

		
end architecture;
	
