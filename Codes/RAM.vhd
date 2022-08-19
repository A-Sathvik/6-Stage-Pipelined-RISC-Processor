library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
library work;
use work.basic.all;

entity RAM is
	generic(
		data_size: integer := 16;
		mem_size: integer := 256);
		
	port(
		data_in: in std_logic_vector(data_size-1 downto 0);
		data_out : out std_logic_vector(data_size-1 downto 0);
		address: in std_logic_vector(data_size-1 downto 0);
		clk, wr_ena, rd_ena, reset: in std_logic);
		
end entity;

architecture logic of RAM is
	type word_bus is array(mem_size-1 downto 0) of std_logic_vector(data_size-1 downto 0);
	signal reg_out: word_bus;
	signal ena: std_logic_vector(mem_size-1 downto 0);
	signal address_concat: std_logic_vector(integer(ceil(log2(real(mem_size))))-1 downto 0);
begin
	
	GEN_REG: 
	for i in 0 to mem_size-1 generate
		REG: reg_generic
			generic map(data_size )
			port map(clk => clk, en => ena(i), 
				Din => data_in, Dout => reg_out(i), clr => reset);
	end generate GEN_REG;
	
	address_concat <= address(integer(ceil(log2(real(mem_size))))-1 downto 0);
	in_decode: process(address_concat, wr_ena)
	begin
		ena <= (others => '0');
		ena(to_integer(unsigned(address_concat))) <= wr_ena;	
	end process;
	
	data_out <= reg_out(to_integer(unsigned(address_concat)));	
end architecture;

