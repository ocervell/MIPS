----------------------------------------------------------------------------------
-- Company: 		 IIT
-- Engineer:		 Olivier Cervello 
-- 
-- Design Name: 
-- Module Name:    top
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
use IEEE.Numeric_Std.all;
use work.cpu_pkg.all;

entity top is
generic(
	addr_size   : positive := 12;   -- in bits
	mem_size    : positive := 4096; -- in bytes (power of two)
	icache_size : positive := 512;  -- in bytes (power of two)
	dcache_size : positive := 256;  -- in bytes (power of two)
	block_size  : positive := 16    -- in bytes (power of two)
);
port(
	clk    	  : in std_logic;
	rst    	  : in std_logic
);
end top;

architecture Behavioral of top is

signal mem_rw : std_logic;
signal mem_addr : std_logic_vector(addr_size-1 downto 0) := (others => '0');
signal mem_data_i, mem_data_o: std_logic_vector(31 downto 0);
signal mem_width: width_size := width_word;

begin

cpu: entity work.cpu
generic map (addr_size   => addr_size, 
				 icache_size => icache_size, 
				 dcache_size => dcache_size, 
				 block_size  => block_size)
port map (clk        => clk,
			 rst        => rst,
			 mem_rw     => mem_rw,
			 mem_width  => mem_width,
			 mem_addr   => mem_addr,
			 mem_data_i => mem_data_o,
			 mem_data_o => mem_data_i);

memory: entity work.memory
generic map (addr_size => addr_size, 
				 mem_size  => mem_size)
port map (clk    => clk,
			 rw     => mem_rw,
			 width  => mem_width,
			 addr   => mem_addr,
			 data_i => mem_data_i,
			 data_o => mem_data_o
			 );
			 
end Behavioral;