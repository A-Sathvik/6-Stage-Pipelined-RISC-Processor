library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ROM is
	generic(mem_size: integer := 256;
		data_size: integer := 16);
	port(
		address: in std_logic_vector(15 downto 0);
		data_out: out std_logic_vector(data_size-1 downto 0);
		rd_ena ,clk : in std_logic);
end entity;

architecture behave of ROM is
	type int_array is array (0 to mem_size-1) of integer;
	signal memory: int_array := (others => 0);
	signal address_concat: std_logic_vector(integer(ceil(log2(real(mem_size))))-1 downto 0);
begin

	address_concat <= address(integer(ceil(log2(real(mem_size))))-1 downto 0);
	process(rd_ena, address_concat)
	begin
		data_out <= std_logic_vector(to_unsigned(memory(to_integer(unsigned(address_concat))),data_size));
	end process;
--testing load/store instructions 
	memory(0)<= 74;
	memory(1) <= 74;
memory(2) <= 139 ;
memory(3) <= 204 ;
memory(4) <= 269 ;
memory(5) <= 334 ;
memory(6) <= 399 ;
memory(7) <= 53404 ; 
--memory(8) <= 49308;
--	memory(9) <= 21003;
--	memory(10) <= 21004;
--	memory(11) <= 21005;
--	memory(12) <= 21006;
--	memory(13) <= 21007;
	memory(8) <= 128;
	memory(9) <= 192;
	memory(10) <= 256;
	memory(11) <= 320;
	memory(12) <=384;
	memory(13) <= 24908;
	memory(14) <= 61516;
	memory(15) <= 128;
	memory(16) <= 192;
	memory(17) <= 256;
	memory(18) <= 320;
	memory(19) <=384;
	memory(20) <= 28748;




-- to test the instructions 
--memory(0) <= 74;
--memory(1) <= 1098 ;
--memory(2) <= 5712 ;
--memory(3) <= 10448;
----memory(3) <= 14304 ;
--memory(4) <= 14879 ;
--memory(5) <= 23114 ;
--memory(6) <= 19466 ;
--memory(7) <= 6083 ;
--memory(8) <= 0 ;
--memory(9) <= 39426; 



end architecture;


--
