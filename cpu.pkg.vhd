library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

PACKAGE cpu_pkg IS

	component reg_32
		port(
			clk      : in std_logic;
			rst      : in std_logic;
			en 	   : in std_logic;
			data_i   : in std_logic_vector(31 downto 0);
			data_o   : out std_logic_vector(31 downto 0)
		);
	end component;

   constant clk_period : time := 10 ns;

	-- Data types
	subtype word 		is std_logic_vector(31 downto 0);
	subtype half_word is std_logic_vector(15 downto 0);
	subtype byte 		is std_logic_vector(7 downto 0);
	
	-- Timing constants
	constant Ta_r		: integer := 4; 				-- Mem access time for read
	constant Td_r		: integer := 2; 				-- Mem additional time for write
	constant TR			: integer := Ta_r + Td_r;  -- Total delay for memory read
	
	constant Ta_w		: integer := 8; 				-- Mem access time for write
	constant Td_w		: integer := 3; 				-- Mem additional time for write
	constant TW			: integer := Ta_w + Td_w;  -- Total delay for memory write
	
	-- Memory types
	constant mem_size : positive := 4096;
	type mem is array ( 0 to mem_size - 1) of std_logic_vector(7 downto 0);
	constant my_Rom : mem := (
	 x"3c", x"04", x"00", x"ff",
	 x"3c", x"05", x"00", x"fe",
	 x"3c", x"06", x"00", x"fd",
	 x"ac", x"04", x"00", x"64",
	 x"ac", x"05", x"00", x"68",
	 x"ac", x"06", x"00", x"6c",
	 x"00", x"80", x"20", x"27",
	 x"00", x"a0", x"28", x"27",
	 x"00", x"c0", x"30", x"27",
	 x"ac", x"04", x"00", x"64",
	 x"ac", x"05", x"00", x"68",
	 x"ac", x"06", x"00", x"6c",
	 x"00", x"85", x"40", x"20",
	 x"00", x"86", x"48", x"20",
	 x"38", x"8a", x"00", x"f9",
	 x"38", x"8c", x"00", x"f6",
	 x"00", x"85", x"68", x"27",
	 x"00", x"a6", x"70", x"27",
	 x"01", x"ae", x"78", x"27",
	 x"ac", x"08", x"00", x"6a",
	 x"ac", x"09", x"00", x"6e",
	 x"ac", x"0a", x"00", x"72",
	 x"ac", x"0b", x"00", x"76",
	 x"ac", x"0b", x"00", x"76",
	 x"ac", x"0c", x"00", x"7a",
	 x"ac", x"0d", x"00", x"7e",
	 x"ac", x"0e", x"00", x"82",
	 x"ac", x"0f", x"00", x"86",
	 x"8c", x"10", x"00", x"3a",
	 x"8c", x"11", x"00", x"6e",
	 x"8c", x"12", x"00", x"72",
	 x"8c", x"13", x"00", x"76",
	 x"8c", x"14", x"00", x"7a",
	 x"8c", x"15", x"00", x"7e",
	 x"8c", x"16", x"00", x"82",
	 x"8c", x"17", x"00", x"86",
	 x"08", x"00", x"00", x"10",
	 OTHERS => x"00"
	);
	type width_size   is (width_byte, width_halfword, width_word);

	
	-- Useful constants to determine instruction
	constant lw_op      : std_logic_vector(5 downto 0) := "100011";
	constant sw_op      : std_logic_vector(5 downto 0) := "101011";
	constant lui_op     : std_logic_vector(5 downto 0) := "001111";
	constant add_funct  : std_logic_vector(5 downto 0) := "100000";
	constant xori_op	  : std_logic_vector(5 downto 0) := "001101";
	constant nor_funct  : std_logic_vector(5 downto 0) := "100111";
	constant beq_op     : std_logic_vector(5 downto 0) := "000100";
	constant j_op	     : std_logic_vector(5 downto 0) := "000010";
	constant jr_funct   : std_logic_vector(5 downto 0) := "001000";
	
END cpu_pkg;