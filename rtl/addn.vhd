library ieee;
use ieee.std_logic_1164.all;

entity addn is
    generic (
        N : integer := 4
    );
    port(
        A  : in  std_logic_vector(N - 1 downto 0);
        B  : in  std_logic_vector(N - 1 downto 0);
        CI : in  std_logic;
        O  : out std_logic_vector(N - 1 downto 0);
        CO : out std_logic
    );
end entity addn;

architecture rtl of addn is
    component add1
        port(
            A  : in  std_logic;
            B  : in  std_logic;
            CI : in  std_logic;
            O  : out std_logic;
            CO : out std_logic
        );
    end component;

    signal C : std_logic_vector(N downto 0);
begin

    C(0) <= CI;

    GEN: for i in N-1 downto 0 generate
        ADD: add1
            port map (
                A => A(i),
                B => B(i),
                CI => C(i),
                O => O(i),
                CO => C(i+1)
            );
    end generate;

    CO <= C(N);
end rtl;
