--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:26:25 03/31/2015
-- Design Name:   
-- Module Name:   D:/Xilinx/Project2/top_tb.vhd
-- Project Name:  Project2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.Numeric_Std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY top_tb IS
END top_tb;
 
ARCHITECTURE behavior OF top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         clk    : IN  std_logic;
         rst    : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk    : std_logic := '0';
   signal rst    : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          clk => clk,
          rst => rst
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	
   -- Stimulus process
 --  stim_proc: process
--   variable instr_addr   : std_logic_vector(11 downto 0) := (11 downto 3 => '0') & "100";
--	variable instr_data   : std_logic_vector(31 downto 0) := (others => '1');
--	variable bit_count    : natural := 31;
--   begin		
--      -- hold reset state for 100 ns.
--      wait for 100 ns;	
--
--      wait for clk_period*10;
--		en 		  <= '0';
--		rw 		  <= '1';
--		addr		  <= instr_addr;
--		data_i     <= instr_data(31 downto 24); 
--		for i in 0 to 500 loop
--			wait for clk_period;
--			data_i     <= instr_data(31 downto 24); 
--			addr		  <= instr_addr;
--			wait for clk_period;
--			data_i	  <= instr_data(23 downto 16); 	
--			addr 		  <= std_logic_vector(unsigned(instr_addr) + 1);
--			wait for clk_period;
--			data_i	  <= instr_data(15 downto 8); 
--			addr 		  <= std_logic_vector(unsigned(instr_addr) + 2);
--			wait for clk_period;
--			data_i     <= instr_data(7 downto 0);
--			addr 		  <= std_logic_vector(unsigned(instr_addr) + 3);
--			instr_data := std_logic_vector(unsigned(instr_data) - 20);
--			instr_addr := std_logic_vector(unsigned(instr_addr) + 4);
--		end loop;  
--		en <= '1';
--      wait;
--   end process;

END;
