library ieee;
use ieee.std_logic_1164.all;

entity digit is
    port(
        input : in std_logic_vector(7 downto 0);
        is_digit : out std_logic
    );
end entity digit;

architecture rtl of digit is
begin
    is_digit <= (not input(7) and not input(6) and input(5) and input(4) and ((input(3) and not input(2) and not input(1)) or (not input(3))));
end rtl;
