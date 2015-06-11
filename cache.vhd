----------------------------------------------------------------------------------
-- Company: 		 IIT
-- Engineer:		 Olivier Cervello 
-- 
-- Design Name: 
-- Module Name:    cache
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

entity cache is
generic (
	cache_size: positive := 512; -- in bytes (power of 2)
	block_size: positive := 16;  -- in bytes (power of 2)
	addr_size : positive := 12   -- in bits
);
port(
	clk        : in std_logic;
-- CPU connections
	cpu_en	  : in std_logic;
	cpu_rw     : in std_logic;
	cpu_done   : out std_logic;
	cpu_addr   : in std_logic_vector(addr_size-1 downto 0);
	cpu_data_i : in std_logic_vector(31 downto 0);
	cpu_data_o : out std_logic_vector(31 downto 0);
-- Memory connections
	mem_rw     : out std_logic  := '0';
	mem_width  : out width_size := width_word;
	mem_addr   : out std_logic_vector(addr_size-1 downto 0) := (others => '0');
	mem_data_i : in  std_logic_vector(31 downto 0);
	mem_data_o : out std_logic_vector(31 downto 0)
);
end cache;

architecture Behavioral of cache is

-- Constants definitions
constant words_per_block : positive := block_size / 4;
constant nb_sets		    : positive := cache_size / block_size;

-- Types for cache
type set is array(0 to words_per_block-1) of word;
type entry is record
	valid : boolean;
	dirty : boolean;
	tag   : natural;
	data  : set;
end record;
type cache_type is array (0 to nb_sets-1) of entry;
type state_type is (init, sleep, get_data, replace_block, read_miss, write_miss, done);

-- Signals
signal CACHE 		  : cache_type;
signal state		  : state_type := init;
signal hit_sig		  : std_logic;
constant clk_period : time := 10ns;

begin	
cache_loop: process(clk)

	variable tag   		 : natural;
	variable index 		 : natural range 0 to nb_sets-1;
	variable offset		 : natural range 0 to words_per_block-1;
	variable word_offset  : natural range 0 to words_per_block-1;
	variable cpu_addr_int : integer;
	variable hit			 : boolean;
	variable bit_count	 : natural range 0 to 31;
	variable mem_addr_tmp : std_logic_vector(addr_size-1 downto 0) := (others => '0');
	variable c				 : integer := 0;
	
	begin
	if rising_edge(clk) then
		case state is
			when init =>
				for i in 0 to nb_sets-1 loop	
					CACHE(i).dirty <= false;
					CACHE(i).valid <= false;
            end loop;
				state <= sleep;
				
			when sleep =>
				cpu_done 	<= '0';
				mem_rw      <= '0';
				hit_sig 		<= '0';
				hit 			:= false;
				word_offset := 0;
				if cpu_en = '1' then
					state <= get_data;
				end if;
				
			when get_data =>
				cpu_addr_int := to_integer(unsigned(cpu_addr));
				c				 := 0;
				
				-- Setting cache fields to read/write cache from cpu address
				offset 		 := (cpu_addr_int mod block_size) / 4;
				index  		 := (cpu_addr_int / block_size) mod nb_sets;
				tag    		 := cpu_addr_int / block_size / nb_sets;
				
				-- Checking for cache hit (block in cache must be valid (already used once), not dirty and tags matching)
				if ((CACHE(index).valid = true) and (CACHE(index).dirty = false) and (CACHE(index).tag = tag)) then
					hit 	  := true;
					hit_sig <= '1';
				end if;
				
				-- Change to appropriate state
				if hit then 				-- HIT
					if cpu_rw = '0' then -- READ
						cpu_data_o 					  <= CACHE(index).data(offset);
						cpu_done  					  <= '1';
						state 		              <= done;
					else						-- WRITE
						CACHE(index).data(offset) <= cpu_data_i;
						CACHE(index).dirty        <= true;
						cpu_done 					  <= '1';
						state    					  <= done;
					end if;
				else				         -- MISS
					mem_width  	 <= width_word;
					if (cpu_rw = '0') then			-- READ
						if CACHE(index).dirty then -- block dirty in memory, write cache block back to memory
							mem_addr_tmp := std_logic_vector(to_unsigned((CACHE(index).tag * nb_sets + index) * block_size, mem_addr_tmp'length));
							mem_addr 	 <= mem_addr_tmp;
							mem_width    <= width_word;
							mem_rw		 <= '1';
							state        <= replace_block;
						else							   -- block not dirty, bring back other block to cache and read from it
							mem_rw       <= '0';
							mem_addr_tmp := std_logic_vector(to_unsigned((to_integer(unsigned(cpu_addr)) / block_size) * block_size, mem_addr_tmp'length));
							state 	    <= read_miss;
						end if;
					else									-- WRITE (no-allocate)
						mem_rw       <= '1';
						mem_addr_tmp := cpu_addr;
						state 	    <= write_miss;
					end if;
					mem_addr 	 <= mem_addr_tmp;
				end if;

			when replace_block =>  -- bring the dirty block from cache to memory
				mem_data_o   <= CACHE(index).data(word_offset);
				c := c + 1;
				if (word_offset = words_per_block-1) then -- end of block transfer
					if (c = 4*TW) then
						word_offset  := 0;
						c := 0;
						mem_rw <= '0';
						mem_addr_tmp := std_logic_vector(to_unsigned((to_integer(unsigned(cpu_addr)) / block_size) * block_size, mem_addr_tmp'length));
						CACHE(index).dirty <= false;
						state  <= read_miss;
					end if;
				else
					word_offset   := word_offset + 1;
					mem_addr_tmp  := std_logic_vector(to_unsigned(to_integer(unsigned(mem_addr_tmp)) + 4, mem_addr_tmp'length));
				end if;
				mem_addr		 <= mem_addr_tmp;
				
			when read_miss => -- bring a block from memory to the cache and read from/write on it
				CACHE(index).data(word_offset) <= mem_data_i; -- write word to cache
				c := c + 1;
				if (word_offset = words_per_block-1) then     -- end of block transfer
					if (c = 4*TR) then
						CACHE(index).valid   <= true;
						CACHE(index).tag     <= tag;
						cpu_data_o 			   <= CACHE(index).data(offset);
						cpu_done             <= '1';
						state 					<= done;
					end if;
				else
					word_offset   := word_offset + 1;
					mem_addr_tmp  := std_logic_vector(to_unsigned(to_integer(unsigned(mem_addr_tmp)) + 4, mem_addr_tmp'length));
					mem_addr      <= mem_addr_tmp;
				end if;
				
			when write_miss => -- write word to memory (no-write allocate)
				c := c + 1;
				mem_data_o <= cpu_data_i;
				if (c = TW) then
					cpu_done	  <= '1';
					state 	  <= done;
				end if;
				
			when done =>
				cpu_done <= '0';
				if (cpu_en = '0') then
					state   <= sleep;
				end if;
		end case;
	end if;
end process;
end Behavioral;