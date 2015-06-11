--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:36:38 03/29/2015
-- Design Name:   
-- Module Name:   D:/Xilinx/Project2/cache_tb.vhd
-- Project Name:  Project2
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cache
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY cache_tb IS
END cache_tb;
 
ARCHITECTURE behavior OF cache_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cache
    PORT(
         clk : IN  std_logic;
         cpu_enable : IN  std_logic;
         cpu_rw : IN  std_logic;
         cpu_done : OUT  std_logic;
         cpu_addr : IN  std_logic_vector(11 downto 0);
         cpu_data : INOUT  std_logic_vector(31 downto 0);
         mem_enable : OUT  std_logic;
         mem_rw : OUT  std_logic;
         mem_done : IN  std_logic;
         mem_addr : OUT  std_logic_vector(11 downto 0);
         mem_data : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal cpu_enable : std_logic := '0';
   signal cpu_rw : std_logic := '0';
   signal cpu_addr : std_logic_vector(11 downto 0) := (others => '0');
   signal mem_done : std_logic := '0';

	--BiDirs
   signal cpu_data : std_logic_vector(31 downto 0);
   signal mem_data : std_logic_vector(7 downto 0);

 	--Outputs
   signal cpu_done : std_logic;
   signal mem_enable : std_logic;
   signal mem_rw : std_logic;
   signal mem_addr : std_logic_vector(11 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	signal cpu_data_tmp: std_logic_vector(31 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cache PORT MAP (
          clk => clk,
          cpu_enable => cpu_enable,
          cpu_rw => cpu_rw,
          cpu_done => cpu_done,
          cpu_addr => cpu_addr,
          cpu_data => cpu_data,
          mem_enable => mem_enable,
          mem_rw => mem_rw,
          mem_done => mem_done,
          mem_addr => mem_addr,
          mem_data => mem_data
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
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
		cpu_enable <= '1';
		cpu_rw <= '1';
		cpu_addr <= "100000000000";
		wait until cpu_done = '1';
		cpu_enable <= '0';
		wait for clk_period*5;
		cpu_enable <= '1';
		cpu_rw <= '1';
		cpu_addr <= "100000000001";
		wait until cpu_done = '1';
		cpu_enable <= '0';
		wait for clk_period*5;
		cpu_enable <= '1';
		cpu_rw <= '0';
		cpu_addr <= "100000000000";
		wait until cpu_done = '1';
		cpu_enable <= '0';
		wait for clk_period*5;
		cpu_enable <= '1';
		cpu_rw <= '0';
		cpu_addr <= "100000000001";
	

      -- insert stimulus here 

      wait;
   end process;
	
	stim_proc3: process(cpu_data_tmp)
	begin
		cpu_data <= cpu_data_tmp;
	end process;
	
	stim_proc2: process
	begin
		wait until cpu_enable = '1';
		mem_loop: loop
		wait for 2*clk_period;
		mem_done <= '1';
		wait for clk_period;
		mem_done <= '0';
		end loop;
	end process;
END;
