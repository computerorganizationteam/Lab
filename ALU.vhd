----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:31:12 10/14/2017 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           DATA : in  STD_LOGIC_VECTOR (15 downto 0);
           R : out  STD_LOGIC_VECTOR (15 downto 0);
           FLAG : out  STD_LOGIC_VECTOR (6 downto 0));
end ALU;

architecture Behavioral of ALU is
--result
signal C : STD_LOGIC_VECTOR(15 downto 0);
--four states
type state is (s0, s1, s2, s3);
signal current:state:= s0;

signal c_alu : STD_LOGIC_VECTOR(3 downto 0):="0000";
signal A : STD_LOGIC_VECTOR(15 downto 0):=x"0000";
signal B : STD_LOGIC_VECTOR(15 downto 0):=x"0000";

signal states_out : STD_LOGIC_VECTOR(3 downto 0);
signal temp_0 : integer range 0 to 4 := 0;

begin
process(CLK, RST)
begin
	if(RST = '0') then
		current <= s0;
	else 
		if(clk'event and clk = '1') then
			if(current = s0) then
				current <= s1;
				A <= data;
			elsif(current = s1) then
				current <= s2;
				B <= data;
			elsif(current = s2) then
				current <= s3;
			elsif(current = s3) then
				current <= s0;
				
			end if;
		end if;
	end if;
end process;

process(current)
variable temp : STD_LOGIC_VECTOR(3 downto 0):= "0000";

begin
	if(current = s1)then
		R <= A;
		temp_0 <= 1;
	elsif(current = s2)then
		R <= B;
		temp_0 <= 2;
	elsif(current = s3)then
		temp := data(3 downto 0);
		temp_0 <= 3;
		c_alu <= temp;
		case c_alu is
			when "0000"=>
				c <= (A + B);
			when "0001"=>
				c <= (A - B);
			when "0010"=>
				c <= (A and B);
			when "0011"=>
				c <= (A or B);
			when "0100"=>
				c <= (A xor B);
			when "0101"=>
				c <= not(A);
			when "0110"=>
				c <= to_STDLOGICVECTOR((to_BITVECTOR(B)) sll (conv_INTEGER(A)));
			when "0111"=>
				c <= to_STDLOGICVECTOR((to_BITVECTOR(B)) srl (conv_INTEGER(A)));
			when "1000"=>
				c <= to_STDLOGICVECTOR((to_BITVECTOR(B)) sra (conv_INTEGER(A)));
			when "1001"=>
				c <= to_STDLOGICVECTOR((to_BITVECTOR(A)) rol (conv_INTEGER(B)));
			when others=>
				c <= "0000000000000000";
		end case;
		R <= c;
	elsif(current = s0)then
		temp_0 <= 4;
		--zuigaowei
		states_out(0) <= c(15);
		--yichu
		if(c_alu = "0000" and A(15) = '0' and B(15) = '0' and c(15) = '1')
			or (c_alu = "0000" and A(15) = '1' and B(15) = '1' and c(15) = '0')
			or (c_alu = "0001" and A(15) = '1' and B(15) = '0' and c(15) = '0')
			or (c_alu = "0001" and A(15) = '0' and B(15) = '1' and c(15) = '1') then
			states_out(1) <= '1';
		else
			states_out(1) <= '0';
		end if;
		--wei0
		if(c = "0000000000000000") then
			states_out(2) <= '1';
		else
			states_out(2) <= '0';
		end if;
		--jinwei
		case c_alu is
			when "0000"=>
				states_out(3)<=(A(15) and B(15))or(A(15) and not c(15))or(B(15) and not c(15));
			
			when others=>
				states_out(3)<='0';
		end case;
		R(3 downto 0) <= states_out;
		
	end if;
end process;

process(temp_0)
begin 
	case temp_0 is
		when 1 => flag <= "0000110";
		when 2 => flag <= "1011011";
		when 3 => flag <= "1001111";
		when 4 => flag <= "1100110";
		when others => flag <= "0111111";
	end case;
end process;
				
end Behavioral;

