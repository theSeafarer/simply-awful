library ieee;
use ieee.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity main_tb is
end main_tb;

architecture TB_ARCHITECTURE of main_tb is
	component main
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		r0_val : out STD_LOGIC_VECTOR(5 downto 0);
		r1_val : out STD_LOGIC_VECTOR(5 downto 0);
		r2_val : out STD_LOGIC_VECTOR(5 downto 0);
		r3_val : out STD_LOGIC_VECTOR(5 downto 0);
		pc_val : out STD_LOGIC_VECTOR(5 downto 0);
		ir_val : out STD_LOGIC_VECTOR(5 downto 0) );
	end component;

	signal clk, reset : STD_LOGIC := '0';

	signal r0_val : STD_LOGIC_VECTOR(5 downto 0);
	signal r1_val : STD_LOGIC_VECTOR(5 downto 0);
	signal r2_val : STD_LOGIC_VECTOR(5 downto 0);
	signal r3_val : STD_LOGIC_VECTOR(5 downto 0);
	signal pc_val : STD_LOGIC_VECTOR(5 downto 0);
	signal ir_val : STD_LOGIC_VECTOR(5 downto 0);

begin

	UUT : main
		port map (
			clk => clk,
			reset => reset,
			r0_val => r0_val,
			r1_val => r1_val,
			r2_val => r2_val,
			r3_val => r3_val,
			pc_val => pc_val,
			ir_val => ir_val
		);

	reset <= '0';
	clk <= not clk after 1 sec;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_main of main_tb is
	for TB_ARCHITECTURE
		for UUT : main
			use entity work.main(main);
		end for;
	end for;
end TESTBENCH_FOR_main;

