library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package basic is

component p_encoder is
	generic(data_width: integer := 16);
	port(
		input: in std_logic_vector(data_width-1 downto 0);
		output: out std_logic_vector(integer(ceil(log2(real(data_width))))-1 downto 0);
		valid: out std_logic); end component;
	component clk_divider is
		generic(ratio: integer := 5);
		port(
			clk_in: in std_logic;
			clk_out: out std_logic);		
	end component;
	
	component reg_generic is
	generic ( data_width : integer :=16);
	port(
		clk, en, clr: in std_logic;
		Din: in std_logic_vector(data_width-1 downto 0);
		Dout: out std_logic_vector(data_width-1 downto 0));
	end component;

	component equal_to is
		generic ( data_width : integer := 16);
		port (
			A, B: in std_logic_vector(data_width-1 downto 0);
			R: out std_logic);
	end component;
	
	component greater_than is
	generic ( data_width : integer := 16);
	port (
		A, B: in std_logic_vector(data_width-1 downto 0);
		R: out std_logic);
	end component;

	component mux4 is
		generic(data_width: integer := 16);
		port(
			inp1, inp2, inp3, inp4: in std_logic_vector(data_width-1 downto 0) := (others => '0');
			sel: in std_logic_vector(1 downto 0);
			output: out std_logic_vector(data_width-1 downto 0));
	end component;

	component mux8 is
		generic(data_width: integer := 16);
		port(
			inp1, inp2, inp3, inp4, inp5, inp6, inp7, inp8: in std_logic_vector(data_width-1 downto 0) := (others => '0');
			sel: in std_logic_vector(2 downto 0);
			output: out std_logic_vector(data_width-1 downto 0));
	end component;
	component fulladder is
	port(
		a, b, cin: in std_logic;	
		cout, s: out std_logic); end component;

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fulladder is
	port(
		a, b, cin: in std_logic;	
		cout, s: out std_logic);
end entity;

architecture logic of fulladder	is
	signal abxor: std_logic;	
begin

	abxor <= (((not a) and b) or (a and (not b)));	
	s <= (((not abxor) and cin) or (abxor and (not cin)));	
	cout <= (((a and b) or (a and cin)) or (cin and b));	

end logic;	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity greater_than is
	generic ( data_width : integer := 16);
	port (
		A, B: in std_logic_vector(data_width-1 downto 0);
		R: out std_logic);
end entity;

architecture logic of greater_than is
	signal not_equal, temp2: std_logic_vector(data_width-1 downto 0);
begin
	
	not_equal <= ((A and (not B)) or ((not A) and B));
	temp2(data_width-1) <= (not not_equal(data_width-1)) or A(data_width-1); 
	gen: for i in data_width-2 downto 0 generate
	temp2(i) <= ((A(i) or (not not_equal(i))) and temp2(i+1)); 
	end generate;
	
	R <= (temp2(0) and not_equal(0));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity equal_to is
	generic ( data_width : integer := 16);
	port (
		A, B: in std_logic_vector(data_width-1 downto 0);
		R: out std_logic);
end entity;

architecture logic of equal_to is
	signal int, temp: std_logic_vector(data_width-1 downto 0);
begin
	int <= ((A and (not B)) or ((not A) and B));	
	temp(0) <= int(0);
    gen: for i in 1 to data_width-1 generate
        temp(i) <= temp(i-1) or int(i);
    end generate; 
    
    R <= not temp(data_width-1);
end logic;

library ieee;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_1164.all;

entity p_encoder is
	generic(data_width: integer := 16);
	port(
		input: in std_logic_vector(data_width-1 downto 0);
		output: out std_logic_vector(integer(ceil(log2(real(data_width))))-1 downto 0);
		valid: out std_logic);
end entity;

architecture behave_ov of p_encoder is
	signal output_temp: std_logic_vector(output'length-1 downto 0);
begin

	main: process(input)
	begin
		output_temp <= (others => '0');
		for i in data_width-1 downto 0 loop
			if input(i) = '1' then
				output_temp <= std_logic_vector(to_unsigned(i,output'length));
			end if;
		end loop;
	end process;
	
	output <= output_temp;
	valid <= '0' when (to_integer(unsigned(output_temp)) = 0 and input(0) = '0') else '1';
	
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity reg_generic is
	generic ( data_width : integer :=16);
	port(clk, en, clr: in std_logic;
		Din: in std_logic_vector(data_width-1 downto 0);
		Dout: out std_logic_vector(data_width-1 downto 0));
end entity;

architecture logic of reg_generic is
begin
	process(clk, clr)	
	begin
		if(clk'event and clk='1') then
			if (en='1') then
				Dout <= Din;
			end if;
		end if;
		if(clr = '1') then
			Dout <= (others => '0');
		end if;
	end process;
	
end logic;		

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity clk_divider is
	generic(ratio: integer := 5);
	port(
		clk_in: in std_logic;
		clk_out: out std_logic);		
end entity;

architecture divider of clk_divider is
	signal inf, outf: std_logic_vector(ratio-1 downto 0);
	
begin
	inf <= std_logic_vector(unsigned(outf) + 1);
	process(clk_in)
	begin
	
		if(clk_in = '1') then
			outf <= inf;
		end if;
	end process;
	clk_out <= outf(ratio - 1);
	
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4 is
	generic(data_width: integer := 16);
	port(
		inp1, inp2, inp3, inp4: in std_logic_vector(data_width-1 downto 0) := (others => '0');
		sel: in std_logic_vector(1 downto 0);
		output: out std_logic_vector(data_width-1 downto 0));
end entity;

architecture logic of mux4 is
begin
	output <= inp1 when (sel = "00") else
		inp2 when (sel = "01") else
		inp3 when (sel = "10") else
		inp4;
end logic;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux8 is
	generic(data_width: integer := 16);
	port(
		inp1, inp2, inp3, inp4, inp5, inp6, inp7, inp8: in std_logic_vector(data_width-1 downto 0) := (others => '0');
		sel: in std_logic_vector(2 downto 0);
		output: out std_logic_vector(data_width-1 downto 0));
end entity;

architecture logic of mux8 is
begin
	output <= inp1 when (sel = "000") else
		inp2 when (sel = "001") else
		inp3 when (sel = "010") else
		inp4 when (sel = "011") else
		inp5 when (sel = "100") else
		inp6 when (sel = "101") else
		inp7 when (sel = "110") else
		inp8;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extend is
	generic(output_width: integer := 16);
	port(
		input: in std_logic_vector(output_width-1 downto 0);
		output: out std_logic_vector(output_width-1 downto 0);
		sel_6_9, bypass: in std_logic);
end entity;

architecture basic of sign_extend is
	signal output_6: std_logic_vector(output_width-1 downto 0) := (others => '0');
	signal output_9: std_logic_vector(output_width-1 downto 0) := (others => '0');
begin
	
	output_6(5 downto 0) <= input(5 downto 0);
	output_9(8 downto 0) <= input(8 downto 0);
	
	extend_6:
	for i in 6 to output_width-1 generate
		output_6(i) <= input(5) and (not bypass);
	end generate;

	extend_9:
	for i in 9 to output_width-1 generate
		output_9(i) <= input(8) and (not bypass);
	end generate;
	
	output <= output_6 when (sel_6_9 = '1') else
		output_9;

end architecture;
