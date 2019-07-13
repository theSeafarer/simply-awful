library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity main is
    port (
        clk, reset : in std_logic;
        r0_val, r1_val, r2_val, r3_val, 
        pc_val, ir_val : out std_logic_vector(5 downto 0)
    );
end main;

architecture main of main is

    component alu is
    port (
        in1 : in std_logic_vector(5 downto 0);
        in2 : in std_logic_vector(5 downto 0);
        cmd : in std_logic_vector(1 downto 0);
        res : out std_logic_vector(5 downto 0)
    );
	end component;
	
	component instr_mem is
	port (
        addr : in std_logic_vector(5 downto 0);
        data : out std_logic_vector(5 downto 0)
    );
	end component;
	
	component reg is
	port (
        clk, reset, ld : in std_logic;
        rin : in std_logic_vector(5 downto 0);
        rout : out std_logic_vector(5 downto 0);
        zr : out std_logic
    );
	end component;
	
	signal zr0_s, zr1_s, zr2_s, zr3_s : std_logic := '0';
	signal ld0_s, ld1_s, ld2_s, ld3_s : std_logic := '0';
	signal rout0_s, rout1_s, rout2_s, rout3_s, rout_pc_s, rout_ir_s : std_logic_vector(5 downto 0) := "000000";
	signal inc_pc_s, rst_pc_s, sel_bus_s : std_logic := '0';
	
	signal bus_s : std_logic_vector(5 downto 0) := "000000";
	signal mem_data_s : std_logic_vector(5 downto 0) := "000000";
	signal alu_in1_s, alu_in2_s, alu_res_s : std_logic_vector(5 downto 0) := "000000";
	signal alu_sel1_s, alu_sel2_s : std_logic_vector(1 downto 0) := "00";
	signal alu_cmd_s : std_logic_vector(1 downto 0) := "10";
	
	signal pc_next, ir_next : std_logic_vector(5 downto 0) := "000000";
	
	-- type ctrl_state is (start, fetch, execute, halt)
	signal ctrl_state : std_logic_vector(1 downto 0) := "00";
	signal next_ctrl_state : std_logic_vector(1 downto 0);

begin
	
	r0: reg port map (
		clk => clk, reset => reset, ld => ld0_s,
		rin => bus_s,
		rout => rout0_s,
		zr => zr0_s
		);
	r1: reg port map (
		clk => clk, reset => reset, ld => ld1_s,
		rin => bus_s,
		rout => rout1_s,
		zr => zr1_s
		);		   
	r2: reg port map (
		clk => clk, reset => reset, ld => ld2_s,
		rin => bus_s,
		rout => rout2_s,
		zr => zr2_s
		);
	r3: reg port map (
		clk => clk, reset => reset, ld => ld3_s,
		rin => bus_s,
		rout => rout3_s,
		zr => zr3_s
		);
  im: instr_mem port map (
		addr => rout_pc_s,
		data => mem_data_s
		);
	al: alu port map (
		in1 => alu_in1_s,
		in2 => alu_in2_s,
		cmd => alu_cmd_s,
		res => alu_res_s
		);

	alu_in1_s <= rout0_s when alu_sel1_s = "00"
			else rout1_s when alu_sel1_s = "01"
			else rout2_s when alu_sel1_s = "10"
			else rout3_s when alu_sel1_s = "11";
				
	alu_in2_s <= rout0_s when alu_sel2_s = "00"
			else rout1_s when alu_sel2_s = "01"
			else rout2_s when alu_sel2_s = "10"
			else rout3_s when alu_sel2_s = "11"; 
				
	r0_val <= rout0_s;
	r1_val <= rout1_s;
	r2_val <= rout2_s;
	r3_val <= rout3_s;
	pc_val <= rout_pc_s;
  ir_val <= rout_ir_s;
    
	bus_s <= mem_data_s when sel_bus_s = '0'
			else alu_res_s;

		
    process(ctrl_state, rout_ir_s, rout_pc_s, bus_s, zr0_s, zr1_s, zr2_s, zr3_s)

			  -- procedure ld_reg(signal reg_id : std_logic_vector(1 downto 0)) is
        -- begin
            
        -- end;
        variable zr : std_logic := '0';

    begin
				ld0_s <= '0'; ld1_s <= '0'; ld2_s <= '0'; ld3_s <= '0';
				pc_next <= rout_pc_s;
				ir_next <= rout_ir_s;

				case ctrl_state is
					when "11" =>
					when "00" =>
						pc_next <= (others => '0');
					when "01" =>
						sel_bus_s <= '0';
						ir_next <= bus_s;
						pc_next <= rout_pc_s + 1;
					when "10" =>

						case rout_ir_s(5 downto 4) is
										when "00" =>  -- LOAD
												sel_bus_s <= '0';
												case rout_ir_s(3 downto 2) is
													when "00" =>
															ld0_s <= '1';
													when "01" =>
															ld1_s <= '1';
													when "10" =>
															ld2_s <= '1';
													when "11" =>
															ld3_s <= '1';
													when others =>
												end case;
												-- inc_pc_s <= '1'; 
												pc_next <= rout_pc_s + 1;                               
										when "01" =>  -- ADD
												sel_bus_s <= '1';
												case rout_ir_s(3 downto 2) is
													when "00" =>
															ld0_s <= '1';
													when "01" =>
															ld1_s <= '1';
													when "10" =>
															ld2_s <= '1';
													when "11" =>
															ld3_s <= '1';
													when others =>
												end case;
												alu_cmd_s <= rout_ir_s(5 downto 4);
												alu_sel1_s <= rout_ir_s(3 downto 2);
												alu_sel2_s <= rout_ir_s(1 downto 0);
										when "10" =>  -- SUB
												sel_bus_s <= '1';
												case rout_ir_s(3 downto 2) is
													when "00" =>
															ld0_s <= '1';
													when "01" =>
															ld1_s <= '1';
													when "10" =>
															ld2_s <= '1';
													when "11" =>
															ld3_s <= '1';
													when others =>
												end case;
												alu_cmd_s <= rout_ir_s(5 downto 4);
												alu_sel1_s <= rout_ir_s(3 downto 2);
												alu_sel2_s <= rout_ir_s(1 downto 0);
										when "11" =>  -- JNZ
												case rout_ir_s(3 downto 2) is
														when "00" => zr := zr0_s;
														when "01" => zr := zr1_s;
														when "10" => zr := zr2_s;
														when "11" => zr := zr3_s;
														when others => zr := '0';
												end case;
												if zr = '1' then
														pc_next <= rout_pc_s + 1;
												else
														sel_bus_s <= '0';
														pc_next <= bus_s;
												end if;	 
										when others =>
														
								end case;
						when others =>
				end case;
    end process;

		
		next_ctrl_state <= "01" when ctrl_state = "00"
			else "10" when ctrl_state = "01"
			else "01" when ctrl_state = "10"
			else "11" when ctrl_state = "11";
			-- no halt

		process(clk, reset)
		begin
				if reset = '1' then
					ctrl_state <= "00";
				elsif rising_edge(clk) then
					ctrl_state <= next_ctrl_state;
					rout_pc_s <= pc_next;
					rout_ir_s <= ir_next;
				end if;
		end process;
end main;