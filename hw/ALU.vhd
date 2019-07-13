library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ALU is
    port (
        in1 : in std_logic_vector(5 downto 0);
        in2 : in std_logic_vector(5 downto 0);
        cmd : in std_logic_vector(1 downto 0);
        res : out std_logic_vector(5 downto 0)
    );
end ALU;

architecture ALU of ALU is
begin
    res <= in1 + in2 when cmd = "01"
        else in1 - in2;
end ALU;