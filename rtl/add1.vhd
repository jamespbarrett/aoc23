library ieee;
use ieee.std_logic_1164.all;

entity add1 is
    port(
        A  : in  std_logic;
        B  : in  std_logic;
        CI : in  std_logic;
        O  : out std_logic;
        CO : out std_logic
    );
end entity add1;

architecture rtl of add1 is
begin
    O  <= A xor B xor CI;
    CO <= (A and B) or ((A xor B) and CI);
end rtl;
