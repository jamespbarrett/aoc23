library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity chardet is
    generic (
        CHAR: character
    );
    port(
        I : in std_logic_vector(7 downto 0);
        Q : out std_logic
    );
end entity chardet;

architecture rtl of chardet is
    constant C: std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(character'pos(CHAR), 8));

    signal E: std_logic_vector(7 downto 0);
begin
    GEN: for n in 7 downto 0 generate
        GEN0: if C(n) = '0' generate
            E(n) <= not I(n);
        end generate;
        GEN1: if C(n) = '1' generate
            E(n) <= I(n);
        end generate;
    end generate;

    Q <= E(7) and E(6) and E(5) and E(4) and E(3) and E(2) and E(1) and E(0);
end rtl;
