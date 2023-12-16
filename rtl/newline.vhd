library ieee;
use ieee.std_logic_1164.all;

entity newline is
    port(
        input : in std_logic_vector(7 downto 0);
        is_newline : out std_logic
    );
end entity newline;

architecture rtl of newline is
begin
    is_newline <= (not input(7) and not input(6) and not input(5) and not input(4) and input(3) and not input(2) and input(1) and not input(0));
end rtl;
