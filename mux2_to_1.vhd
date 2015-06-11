----------------------------------------------------------------------------------
-- Company: 		 IIT
-- Engineer:		 Olivier Cervello 
-- 
-- Design Name: 
-- Module Name:    Mux 2-to-1
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

entity mux2to1 is
generic(
	data_size: positive := 31
);
port(
	in1: in std_logic_vector(data_size-1 downto 0);
	in2: in std_logic_vector(data_size-1 downto 0);
	s  : out std_logic_vector(data_size-1 downto 0);
	sel: in std_logic
);
end mux2to1;

architecture Behavioral of mux2to1 is
begin
process(sel, in1, in2)
begin
	case(sel) is 
		when '0'     => s <= in1;
		when '1'     => s <= in2; 
		when others  => s <= in1;
	end case;
end process;
end Behavioral;