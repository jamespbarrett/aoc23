library ieee;
use ieee.std_logic_1164.all;

entity sel is
    generic (
        N : integer := 1
    );
    port(
        A : in std_logic_vector(N - 1 downto 0);
        B : in std_logic_vector(N - 1 downto 0);
        S : in std_logic;
        Q : out std_logic_vector(N - 1 downto 0)
    );
end entity sel;

architecture rtl of sel is
begin
    GEN: for i in N-1 downto 0 generate
        Q(i) <= (A(i) and not S) or (B(i) and S);
    end generate;
end rtl;
