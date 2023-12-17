library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity chardet_tb is
end entity chardet_tb;

architecture test of chardet_tb is
    signal stop_sim : boolean := false;

    signal I : std_logic_vector(7 downto 0);
    signal Q : std_logic;

    component chardet
        generic (
            CHAR: character
        );
        port(
            I : in std_logic_vector(7 downto 0);
            Q : out std_logic
        );
    end component;

    signal good : boolean;
begin

    UUTA: chardet
        generic map (
            CHAR => 'a'
        )
        port map (
            I => I,
            Q => Q
        );

    stim: process 
    begin
        stop_sim <= false;
        I <= (others => '0');
        good <= true;

        for n in 0 to 255 loop
            I <= std_logic_vector(to_unsigned(n, 8));

            wait for 10 ns;

            good <= (Q = '1') when (n = character'pos('a')) else (Q = '0');
        end loop;

        wait for 100 ns;
        stop_sim <= true;
        wait;
    end process stim;

end architecture test;