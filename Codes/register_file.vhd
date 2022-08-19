library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
library work;
use work.basic.all;
-- register file of size 16 each holding 8 bits
entity register_file is
	generic(
		data_width: integer := 16;
		data_size: integer := 8);
		
	port(
		reg_write_data, R7_in: in std_logic_vector(data_width-1 downto 0);
		reg_read_data1, reg_read_data2, R0,R1,R2,R3,R4,R5,R6,R7_out: out std_logic_vector(data_width-1 downto 0);
		reg_write_dest,reg_read_addr_1, reg_read_addr_2: in std_logic_vector(2 downto 0);
		clk, reg_write_en, R7_en, reset: in std_logic);
		
end entity;

architecture logic of register_file is
	type word_bus is array(data_size-1 downto 0) of std_logic_vector(data_width-1 downto 0);
	signal reg_out: word_bus;
	signal en: std_logic_vector(data_size-1 downto 0);
	--signal data_out,
signal	R7_reg_in: std_logic_vector(data_width-1 downto 0);
	
begin
	
	REG: 
	for i in 0 to data_size-2 generate
		REG: reg_generic
			generic map(data_width)
			port map(clk => clk, en => en(i), 
				Din => reg_write_data, Dout => reg_out(i), clr => reset);
	end generate REG;
	
	R7: reg_generic
		generic map(data_width)
		port map(clk => clk, en => en(7), 
			Din => R7_reg_in, Dout => reg_out(7), clr => reset);
	
	R7_reg_in <= R7_in when (R7_en = '1')
		else reg_write_data;
		
	select_register: process(reg_write_dest, reg_write_en, R7_en)
	begin
		en <= (others => '0');
		en(to_integer(unsigned(reg_write_dest))) <= reg_write_en;
		en(7) <= R7_en;
	end process;
	
	reg_read_data1 <= reg_out(to_integer(unsigned(reg_read_addr_1)));
	reg_read_data2 <= reg_out(to_integer(unsigned(reg_read_addr_2)));
	R0 <= reg_out(0);
		R1 <= reg_out(1);
			R2 <= reg_out(2);
		R3 <= reg_out(3);
	R4 <= reg_out(4);
	R5 <= reg_out(5);
		R6 <= reg_out(6);
			R7_out <= reg_out(7);

end architecture;