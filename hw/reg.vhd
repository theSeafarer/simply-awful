library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity reg is
    port (
        clk, reset, ld : in std_logic;
        rin : in std_logic_vector(5 downto 0);
        rout : out std_logic_vector(5 downto 0);
        zr : out std_logic
    );
end reg;

architecture reg of reg is

    signal val : std_logic_vector(5 downto 0) := "000000";

begin

    process(clk, reset)
    begin
        if reset = '1' then   -- we probably won't use this
            val <= (others => '0');
        elsif rising_edge(clk) then
            val <= val;
            if ld = '1' then
                val <= rin;
            end if;
        end if;
    end process;

    rout <= val;
    zr <= '1' when val = "000000"
        else '0';

end reg ;