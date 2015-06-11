----------------------------------------------------------------------------------
-- Company: 		 IIT
-- Engineer:		 Olivier Cervello 
-- 
-- Design Name: 
-- Module Name:    cpu
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
use IEEE.numeric_std.all;
use work.cpu_pkg.all;

entity cpu is
generic(
	addr_size  : positive := 12;  -- in bits
	icache_size: positive := 512; -- in bytes (power of two)
	dcache_size: positive := 256; -- in bytes (power of two)
	block_size : positive := 16   -- in bytes (power of two)
);
port(
	clk	       : in std_logic;
	rst	       : in std_logic;
	-- Memory connections
	mem_rw       : out std_logic;
	mem_width	 : out width_size := width_word;
	mem_addr     : out std_logic_vector(addr_size-1 downto 0) := (others => '0');
	mem_data_i   : in std_logic_vector(31 downto 0);
	mem_data_o   : out std_logic_vector(31 downto 0)
);
end cpu;

architecture Behavioral of cpu is

-- Type definitions
type state_type 		 is (IFe,     -- Instruction Fetch
								  ID,      -- Instruction Decode
								  EX,      -- Instruction Execute
								  MM,      -- Memory Access 
								  WB);     -- Write Back
type reg_array 		 is array(0 to 31) of std_logic_vector(31 downto 0);
type instruction_type is (R_type, I_type, LS_type, J_type, JR_type);

-- FSM signals
signal if_done, id_done, ex_done, mm_done, wb_done: std_logic := '0';
signal state : state_type := Ife;

-- Registers signals
signal pc		     			   : std_logic_vector(31 downto 0) := (others => '0');
signal new_pc						: std_logic_vector(31 downto 0) := (others => '0');
signal ir			   			: std_logic_vector(31 downto 0) := (others => '0');
signal mdr			   			: std_logic_vector(31 downto 0) := (others => '0');
signal regs							: reg_array 						  := (OTHERS => (others=>'0'));

-- Cache signals
signal mem_addr_i 				: std_logic_vector(addr_size-1 downto 0);
signal mem_data_o_i				: std_logic_vector(31 downto 0);									  
signal icache_en					: std_logic := '1';
signal mem_rw_i    				: std_logic;

signal mem_addr_d 				: std_logic_vector(addr_size-1 downto 0);
signal mem_data_o_d 			   : std_logic_vector(31 downto 0);	
	
signal dcache_data_i		      : std_logic_vector(31 downto 0);										  				 			  
signal dcache_rw, mem_rw_d    : std_logic; 												  						 												  			
signal dcache_en			      : std_logic;

-- Instruction
signal instr_type: instruction_type;
alias opcode : std_logic_vector(5 downto 0)  is ir(31 downto 26);
alias rs		 : std_logic_vector(4 downto 0)  is ir(25 downto 21);
alias rt		 : std_logic_vector(4 downto 0)  is ir(20 downto 16);
alias rd		 : std_logic_vector(4 downto 0)  is ir(15 downto 11);
alias shamt  : std_logic_vector(4 downto 0)  is ir(10 downto 6 );
alias funct  : std_logic_vector(5 downto 0)  is ir(5  downto 0 );
alias imm    : std_logic_vector(15 downto 0) is ir(15 downto 0 );
alias offset : std_logic_vector(15 downto 0) is ir(15 downto 0 );
alias target : std_logic_vector(25 downto 0) is ir(25 downto 0 );

signal rs_int, rt_int, rd_int, imm_int, shamt_int, offset_int, opcode_int, funct_int: integer := 0;

signal ALU_out : std_logic_vector(31 downto 0) := (others => '0');
signal sel		: std_logic := '0';

begin
			
-- Cache
icache: entity work.cache
generic map (cache_size => icache_size, block_size => block_size, addr_size => addr_size)
port map(clk        => clk,
		   cpu_en     => icache_en, 
			cpu_rw     => '0',
			cpu_done   => if_done,
			cpu_addr   => pc(addr_size-1 downto 0), 
			cpu_data_i =>(others => '0'),
			cpu_data_o => ir, 
			mem_rw     => mem_rw_i, 
			mem_addr   => mem_addr_i, 
			mem_data_i => mem_data_i, 
			mem_data_o => mem_data_o_i);

dcache: entity work.cache
generic map (cache_size => dcache_size, block_size => block_size, addr_size => addr_size)
port map(clk => clk,
			cpu_en     => dcache_en, 
			cpu_rw     => dcache_rw, 
			cpu_done   => mm_done, 
			cpu_addr   => ALU_out(addr_size-1 downto 0), 
			cpu_data_i => dcache_data_i, 
			cpu_data_o => mdr, 
			mem_rw	  => mem_rw_d, 
			mem_addr   => mem_addr_d, 
			mem_data_i => mem_data_i, 
			mem_data_o => mem_data_o_d);

mux_addr: entity work.mux2to1
generic map (data_size => addr_size)
port map (in1 => mem_addr_i, -- from icache
			 in2 => mem_addr_d, -- from dcache
			 s	  => mem_addr,
			 sel => sel);
			 
mux_data_o: entity work.mux2to1
generic map (data_size => 32)
port map (in1 => mem_data_o_i, -- from icache
			 in2 => mem_data_o_d, -- from dcache
			 s   => mem_data_o,
			 sel => sel);
			 
mux_rw: entity work.mux2to1
generic map (data_size => 1)
port map (in1  => (0 => mem_rw_i),     -- from icache
			 in2  => (0 => mem_rw_d),     -- from dcache
			 s(0) => mem_rw,
			 sel  => sel);
		
		
state_proc: process(clk, rst)
begin
	if rst = '1' then
		state <= Ife;
	elsif rising_edge(clk) then
		case state is 
			when IFe => -- Instruction Fetch;
				if if_done = '1' then
					state <= ID;
				end if;
			when ID  => -- Instruction Decode
				if id_done = '1' then
					state <= EX;
				end if;
			when EX => -- Instruction Execute 
				if ex_done = '1' then
					state <= MM;
				end if;
			when MM => -- Memory access
				if instr_type = LS_type then
					if mm_done = '1' then
						state  <= WB;
					end if;
				else
					state  <= WB;
				end if;
			when WB => -- Write Back
				if wb_done = '1' then
					state <= IFe;
				end if;
			when others =>
				state <= Ife;
		end case;
	end if;
end process;

state_proc_output: process(state)

constant pc_add: std_logic_vector(31 downto 0) := (31 downto 3 => '0') & "100";

procedure decode_instr is -- Decodes the instruction
begin
	case opcode is
		when "000000" => 						
			if (funct = jr_funct) then 	-- J-type
				instr_type   <= J_type;
			else									-- R-type
				instr_type   <= R_type;
			end if;		
		when j_op | beq_op =>    			-- J-type
			instr_type      <= J_type;
		when lw_op | sw_op =>				-- LS-type
			instr_type      <= LS_type;
		when others =>						   -- I-type
			instr_type      <= I_type;
	end case;
	id_done <= '1';
end decode_instr;

procedure exec_instr is -- Executes the instruction (ALU)
variable cond: integer := 0;
begin
	case instr_type is
		when LS_type  =>
			ALU_out    <= std_logic_vector(to_unsigned(offset_int + to_integer(signed(rs)), ALU_out'length));
			case opcode is 
				when lw_op =>
					dcache_rw     <= '0';
					dcache_en     <= '1';
				when sw_op =>
					dcache_rw     <= '1';
					dcache_en     <= '1';
					dcache_data_i <= regs(rt_int);
				when others =>
					null;
			end case;
			pc <= new_pc;
		when R_type  =>
			case funct is
				when add_funct =>
					ALU_out <= std_logic_vector(signed(regs(rs_int)) + signed(regs(rt_int)));
				when nor_funct =>
					ALU_out <= regs(rs_int) nor regs(rt_int);
				when others =>
					null;
			end case;
			pc <= new_pc;
		when I_type =>
			case opcode is
				when lui_op =>
					ALU_out <= imm & (imm'length-1 downto 0 => '0');
				when xori_op =>
					ALU_out <= regs(rs_int) xor (31 downto imm'length => '0') & imm;
				when others =>
					null;
			end case;
			pc <= new_pc;
		when J_type  =>
			case opcode is
				when "000000" =>
					case funct is
						when jr_funct =>
							ALU_out <= regs(rs_int);
							pc      <= regs(rs_int);
						when others =>
							null;
					end case;
				when j_op     =>
					ALU_out <= (31 downto target'length => '0') & target;
					pc      <= (31 downto target'length => '0') & target;
				when beq_op   =>
					if regs(rs_int) = regs(rt_int) then
						cond 			 := 1;
						ALU_out 		 <= (31 downto offset'length => '0') & offset;
					end if;
					if cond = 1 then
						pc <= std_logic_vector(to_unsigned(to_integer(unsigned(new_pc)) + offset_int, pc'length));
					else
						pc <= new_pc;
					end if;	
				when others =>
					null;
			end case;
		when others =>
			null;
	end case;
	ex_done <= '1';
end exec_instr;

begin
	case state is
		when Ife  =>
			sel		  <= '0';
			icache_en  <= '1';
			wb_done    <= '0';
			new_pc	  <= std_logic_vector(unsigned(pc) + unsigned(pc_add));
		when ID   =>
			sel		  <= '1';
			icache_en  <= '0';
			rs_int     <= to_integer(unsigned(rs));
			rt_int     <= to_integer(unsigned(rt));
			rd_int     <= to_integer(unsigned(rd));
			shamt_int  <= to_integer(unsigned(shamt));
			imm_int    <= to_integer(signed(imm));
			offset_int <= to_integer(signed(offset));
			opcode_int <= to_integer(unsigned(opcode));
			funct_int  <= to_integer(unsigned(funct));
			decode_instr;
		when EX	 =>
			id_done    <= '0';
			sel		  <= '1';
			exec_instr;
		when MM =>
			ex_done    <= '0';
			sel		  <= '1';
		when WB   =>
			sel		  <= '1';
			dcache_en  <= '0';
			icache_en  <= '1';
			wb_done 	  <= '1';
			case instr_type is
				when R_type  =>
					regs(rd_int) <= ALU_out;
				when I_type  =>
					regs(rt_int) <= ALU_out;
				when LS_type =>
					if opcode = lw_op then
						regs(rt_int) <= mdr;
					end if;
				when others =>
					null;
			end case;
		when others =>
			null;
	end case;
end process;
end Behavioral;