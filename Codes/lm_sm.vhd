library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.basic.all;

entity LM_SM is 
	port(PRIOR_SEL : in std_logic; 
		data_in: in std_logic_vector(7 downto 0);
		LM, SM ,clk, reset: in std_logic;
		reg_read_addr_2 : out std_logic_vector(2 downto 0);
		reg_read_addr_3 : out std_logic_vector(2 downto 0);
		clear, disable, RF_DO1_mux, ALU2_mux, AR3_mux, mem_in_mux, AR2_mux, input_mux: out std_logic);
end entity;

architecture logic of LM_SM is

type fsm_state is (S1, S2, S3,S4);
signal Q, nQ: fsm_state;
signal set_zero,valid,invalid_next , enable :std_logic := '0';
signal address :std_logic_vector(2 downto 0) := "000";
signal temp_data_in : std_logic_vector(7 downto 0);
component ls_multiple is
	generic(data_size: integer := 8);
	port(
		data_in: in std_logic_vector(data_size-1 downto 0);
		ena, clk, set_zero, reset: in std_logic;
		valid, invalid_next: out std_logic;
		address: out std_logic_vector(integer(ceil(log2(real(data_size))))-1 downto 0));
	
end component;


begin
   temp_data_in <= "11111111" when( PRIOR_SEL = '1') else data_in;
 	LS: ls_multiple
		generic map(8)
		port map(data_in => temp_data_in, 
			 ena => enable,  
             		 clk => clk, 
			 reset => reset, 
			 set_zero => set_zero, 
			 valid => valid, 
			 invalid_next => invalid_next,
			 address => address);
	--reg_read_addr_2 <= address;	
	reg_read_addr_3 <= address;
	--------------------------------------------------------------------
	clock: process(clk)
	begin
		if (clk'event and clk = '1') then
			Q <= nQ;
		end if;
	end process;
    --------------------------------------------------------------------
	mealy: process(clk,reset,Q)
	begin
		case Q is 
		    -----------------------------
			when S1 =>
				set_zero <= '0';
				clear <= '0';
				disable <= '0';
				enable <= LM or SM;  -- for the LS multiple
				if(LM = '1') then 
					nQ <= S2;
				elsif(SM = '1') then
					reg_read_addr_2 <= address;
					nQ <= S3;	
				else 
					nQ <= S1;
				end if;
				------------------
				RF_DO1_mux <= '0';
				AR2_mux <= '0';
				if(LM = '1') then 
					mem_in_mux <= '1'; 
					ALU2_mux <= '1';
					AR3_mux <= '1'; 
				else     -- control signals of RR-EX
					mem_in_mux <= '0'; 
					ALU2_mux <= '0';
					AR3_mux <= '0';
				end if; 
			----------------------------
			when S2 => 
				if(valid = '1') then
					set_zero <= '1';
					clear <= '0';
					nQ <= S2;
					disable <= '1';
					enable <= '0';				
					--------------
					RF_DO1_mux <= '1';
					AR2_mux <= '0';
					mem_in_mux <= '1';
					ALU2_mux <= '1';
					AR3_mux <= '1';
				
				else  
					nQ <= S1;
					clear <= '1';
					disable <= '1';				-- Discussed. To add one bubble. Clear is asynchronous.
					enable <= '0';
					set_zero <= '1';
					--------------
					RF_DO1_mux <= '0';
					AR2_mux <= '0';
					mem_in_mux <= '0';
					ALU2_mux <= '0';
					AR3_mux <= '0';
				
				end if;
				
			-----------------------------
			when S3 =>  
				set_zero <= '1';
				nQ <= S4;
				enable <= '0';
				clear <= '0';
				disable <= '0';
				---------------
				RF_DO1_mux <= '0';
				AR2_mux <= '1';
				mem_in_mux <= '1';
				ALU2_mux <= '1';
				AR3_mux <= '0';
				
			-----------------------------
			when S4 => 
				if(valid = '1') then
					set_zero <= '1' ;
					nQ <= S4;
					disable <= '1';
					clear <= '0';
					enable <= '0';
					---------------
					RF_DO1_mux <= '1';
					AR2_mux <= '1';
					mem_in_mux <= '1';
					ALU2_mux <= '1';
					AR3_mux <= '0';
				else  
					nQ <= S1;
					clear <= '0';
					disable <= '0';
					enable <= '0';
					----------------
					RF_DO1_mux <= '0';
					AR2_mux <= '0';
					mem_in_mux <= '0';
					ALU2_mux <= '0';
					AR3_mux <= '0';
				end if;
		end case;
	end process;
end architecture;

