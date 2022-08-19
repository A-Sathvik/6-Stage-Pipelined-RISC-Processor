 	library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package airthmetic is

	component adder is
	generic(	data_size: integer := 16);
	port(
		x, y: in std_logic_vector(data_size-1 downto 0);
		Sum: out std_logic_vector(data_size-1 downto 0);
		cin: in std_logic;
		Cout: out std_logic); end component;
component adder2Bit is
	port(
		a, b : std_logic_vector(1 downto 0);
		cin: in std_logic;	
		s : out std_logic_vector(1 downto 0);
		cout: out std_logic);	end component;
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
	generic(	data_size: integer := 16);
	port(
		x, y: in std_logic_vector(data_size-1 downto 0);
		Sum: out std_logic_vector(data_size-1 downto 0);
		cin: in std_logic;
		Cout: out std_logic);
end entity;

architecture logic of adder is
	signal x_ext , y_ext, tmp_i3, result_i3 : std_logic_vector( 16 downto 0 ) ;
	signal integer_Cin : integer;
begin
	x_ext(16) <= '0' ; x_ext( 15 downto 0 ) <= x ;
	y_ext(16) <= '0' ; y_ext( 15 downto 0 ) <= y ;
	tmp_i3 <= std_logic_vector( unsigned(x_ext) + unsigned(y_ext) ) ;
	
	integer_Cin <= 1 when Cin='1' else 0 ;
	result_i3 <= std_logic_vector( unsigned( tmp_i3 ) + integer_Cin ) ;
	Cout <= result_i3(16) ; sum <= result_i3( 15 downto 0 ) ;
end architecture;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.basic.all;
entity adder2Bit is
	port(
		a, b : std_logic_vector(1 downto 0);
		cin: in std_logic;	
		s : out std_logic_vector(1 downto 0);
		cout: out std_logic);	
end entity;

architecture logic of adder2Bit is
	signal temp_c: std_logic;
begin
	full1: fullAdder port map( a =>a(0), b=>b(0), s => s(0), cin => cin, cout => temp_c);	
	full2: fullAdder port map( a =>a(1), b=>b(1), s => s(1), cin => temp_c, cout => cout);	
end logic;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.airthmetic.all;
entity adder8Bit is
	port(
		a, b: in std_logic_vector(7 downto 0);
		S: out std_logic_vector(7 downto 0);
		cin: in std_logic;	
		cout: out std_logic);
end entity;

architecture logic of adder8Bit is
	signal c: std_logic_vector(2 downto 0);	
	
begin

	full21: adder2Bit port map(a(0) =>a(0),a(1)=>a(1),b(0)=>b(0), b(1)=>b(1),s(0) => s(0),s(1) => s(1),cin =>cin,cout=>c(0));
	full22: adder2Bit port map( a(0) =>a(2),a(1)=>a(3),b(0)=>b(2), b(1)=>b(3),s(0) => s(2),s(1) => s(3),cin =>c(0),cout=>c(1));
	full23: adder2Bit port map( a(0) =>a(4),a(1)=>a(5),b(0)=>b(4), b(1)=>b(5),s(0) => s(4),s(1) => s(5),cin =>c(1),cout=>c(2));
	full24: adder2Bit port map(  a(0) =>a(6),a(1)=>a(7),b(0)=>b(6), b(1)=>b(7),s(0) => s(6),s(1) => s(7),cin =>c(2),cout=>cout);

end logic;