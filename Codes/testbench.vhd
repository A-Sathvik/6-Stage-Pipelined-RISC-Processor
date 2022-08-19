library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all ;
--use ieee.std_logic_textio.all; -- to compile add option --ieee=synopsys

entity testbench is
end entity;

architecture test of testbench is
    component main is
        port(
        reset, clk: in std_logic;
		disp0,Disp1,disp2,disp3,disp4,disp5,disp6,disp7: out std_logic_vector(15 downto 0));
    end component;
    signal clk, reset: std_logic := '0';
	signal disp0,Disp1,disp2,disp3,disp4,disp5,disp6,disp7:  std_logic_vector(15 downto 0);
begin
    process
    begin
        wait for 5 ns;
        clk <= not clk;
    end process;
    
    process
    begin
        reset <= '1';
        wait until (clk = '1');
        wait until (clk = '1');
        reset <= '0';
        wait;
    end process;
	
    instance: main
    port map(reset => reset, clk => clk,disp0 => disp0,Disp1 => disp1,disp2=> disp2,disp3=>disp3,
	 disp4 => disp4,disp5 =>disp5,disp6=>disp6,disp7 =>disp7 );
    
end architecture;