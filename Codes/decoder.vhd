library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity decoder is
	port( flags : in std_logic_vector(1 downto 0) ;
		instruction: in std_logic_vector(15 downto 0);
		sign_ext, DEC_PC, LS_PC, LSI: out std_logic; 
		LM, SM, LW, SIGN_D2, BEQ: out std_logic;
		WRITE_BACK_MUX, REG_ADDR1, REG_ADDR2, REG_ADDR3, valid, FLAG_CONTROL: out std_logic_vector(2 downto 0);
		ALU_CONTROL, CZ, WR: out std_logic_vector(1 downto 0)
		);
end entity;

architecture decode of decoder is
	signal RA, RB, RC: std_logic_vector(2 downto 0);
	signal check_cz : std_logic_vector(1 downto 0);
begin

	RA <= instruction(11 downto 9);
	RB <= instruction(8 downto 6);
	RC <= instruction(5 downto 3);
		check_cz<= instruction(1 downto 0);
	
	MAIN: process(instruction, RA, RB, RC,flags,check_cz)
	begin
	
		-- default 
		sign_ext <= '-';
		LS_PC <= '-';
		LSI <= '0';
		CZ <= instruction(1 downto 0);
	
		LM <= '0';SM <= '0';LW <= '0';DEC_PC <= '0';BEQ <= '0';SIGN_D2 <= '0';
		WRITE_BACK_MUX <= "000";
		FLAG_CONTROL <= "111";
		WR <= "10";
		valid <= "111";
		ALU_CONTROL <= "10";
		
	--- RC destination 
-- RA, RB source 	
		REG_ADDR1 <= RA;
		REG_ADDR2 <= RB;
		REG_ADDR3 <= RC;
		case instruction(15 downto 12) is --ADD,ADC,ADZ,ADL
			when "0001" =>		if (check_CZ = "11") then 	REG_ADDR3 <= RC; 
									elsif(check_cz = "10") then 
														if ( flags(1) = '0') then  REG_ADDR3 <= "---"; end if;
									elsif(check_cz = "01")  then
														if ( flags(0) = '0') then  REG_ADDR3 <= "---"; end if; 
									end if;
			 
			when "0000" =>			--ADI
				sign_ext <= '1';
				SIGN_D2 <= '1';
				REG_ADDR3 <= RB;
				REG_ADDR2 <= "---";
				cz <= "00";
				valid <= "101";
		when "0010" =>			--NAND NDU
				sign_ext <= '0';
				SIGN_D2 <= '0';
					REG_ADDR1 <= RA;
				REG_ADDR2 <= RB;
				
				valid <= "101";
				ALU_CONTROL <= "00";
				if(check_cz = "10") then 
														if ( flags(1) = '0') then  REG_ADDR3 <= "---"; end if;
									elsif(check_cz = "01")  then
														if ( flags(0) = '0') then  REG_ADDR3 <= "---"; end if; 
									else  REG_ADDR3 <= RC;
									end if;
				
		when "0011" =>			--LHI
				sign_ext <= '0';
				LS_PC <= '1';
				SIGN_D2 <= '-';
				WRITE_BACK_MUX <= "001";
				ALU_CONTROL <= "--";
				FLAG_CONTROL <= "000";
				REG_ADDR1 <= "---";
				REG_ADDR2 <= "---";
				REG_ADDR3 <= RA;
				valid <= "001";
				
			when "0100" =>			--Load
				sign_ext <= '1';
				LW <= '1';
				SIGN_D2 <= '1';
				WRITE_BACK_MUX <= "100";
				FLAG_CONTROL <= "001";
				REG_ADDR1 <= RB;
				REG_ADDR2 <= "---";
				REG_ADDR3 <= RA;
				valid <= "101";
				
			when "0101" => 			--Store
				sign_ext <= '1';
				SIGN_D2 <= '1';
				WRITE_BACK_MUX <= "---";
				FLAG_CONTROL <= "000";
				WR <= "01";
				REG_ADDR1 <= RB;
				REG_ADDR2 <= RA;
				REG_ADDR3 <= "---";
				valid <= "110";
				
			when "1100" => 			--LM
				LM <= '1';
				SIGN_D2 <= '-';
				WRITE_BACK_MUX <= "100";
				FLAG_CONTROL <= "000";
				REG_ADDR2 <= "---";
				REG_ADDR3 <= "---";
				valid <= "101";
				
			when "1101" =>			--SM
				SM <= '1';
				SIGN_D2 <= '-';
				WRITE_BACK_MUX <= "---";
				FLAG_CONTROL <= "000";
				WR <= "01";
				REG_ADDR2 <= "---";
				REG_ADDR3 <= "---";
				valid <= "110";
			when "1110" => 			--LA
				LM <= '1';
				SIGN_D2 <= '-';
				WRITE_BACK_MUX <= "100";
				FLAG_CONTROL <= "000";
				REG_ADDR2 <= "---";
				REG_ADDR3 <= "---";
				valid <= "101";
				
			when "1111" =>			--SA
				SM <= '1';
				SIGN_D2 <= '-';
				WRITE_BACK_MUX <= "---";
				FLAG_CONTROL <= "000";
				WR <= "01";
				REG_ADDR2 <= "---";
				REG_ADDR3 <= "---";
				valid <= "110";	
				
				
			when "1000" =>			--BEQ
				sign_ext <= '1';
				LS_PC <= '0';
				BEQ <= '1';
				WRITE_BACK_MUX <= "---";
				ALU_CONTROL <= "01";
				FLAG_CONTROL <= "000";
				WR <= "00";
				REG_ADDR3 <= "---";
				valid <= "110";
				
			when "1001" =>			--JAL
				sign_ext <= '0';
				DEC_PC <= '1';
				LS_PC <= '0';
				SIGN_D2 <= '-';
				WRITE_BACK_MUX <= "011";
				ALU_CONTROL <= "--";
				FLAG_CONTROL <= "000";
				WR <= "10";
				REG_ADDR1 <= "---";
				REG_ADDR2 <= "---";
				REG_ADDR3 <= RA;
				valid <= "001";
				
			when "1010" =>			--JLR
				SIGN_D2 <= '-';
				FLAG_CONTROL <= "011";
				ALU_CONTROL <= "--";
				FLAG_CONTROL <= "000";
				WR <= "10";
				REG_ADDR1 <= RB;
				REG_ADDR2 <= "---";
				REG_ADDR3 <= RA;
				valid <= "101";
			when "1011" =>			--JRI
				sign_ext <= '0';
				DEC_PC <= '1';
				LS_PC <= '0';
				SIGN_D2 <= '-';
				WRITE_BACK_MUX <= "---";
				ALU_CONTROL <= "--";
				FLAG_CONTROL <= "000";
				WR <= "00";
				REG_ADDR1 <= RB;
				REG_ADDR2 <= "---";
			--	REG_ADDR3 <= RA;
				valid <= "101";
				
			when others =>
		end case;
	end process;
end architecture;