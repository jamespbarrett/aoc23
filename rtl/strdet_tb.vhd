library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity strdet_tb is
end entity strdet_tb;

architecture test of strdet_tb is
    signal stop_sim : boolean := false;

    signal clock : std_logic;
    signal reset : std_logic;

    signal I : std_logic_vector(7 downto 0);
    signal Q : std_logic;

    component strdet
        generic (
            STR: string
        );
        port(
            clock : std_logic;
            reset : std_logic;
    
            I : in std_logic_vector(7 downto 0);
            Q : out std_logic
        );
    end component;

    signal good : boolean;
begin

    UUTA: strdet
        generic map (
            STR => "one"
        )
        port map (
            clock => clock,
            reset => reset,

            I => I,
            Q => Q
        );

    process begin
        while not stop_sim loop
            clock <= '0';
            wait for 5 ns;
            clock <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    stim: process
        constant INSTRING : string := "ulgondfehsgifonedlk hcdnsnoeg798. [';a;ous";
    begin
        stop_sim <= false;
        I <= (others => '0');
        reset <= '0';
        good <= true;

        wait for 100 ns;

        reset <= '1';

        wait until falling_edge(clock);

        for n in 1 to INSTRING'length loop
            I <= std_logic_vector(to_unsigned(character'pos(INSTRING(n)), 8));

            wait until falling_edge(clock);

            good <= (Q = '1') when (n = 16) else (Q = '0');
        end loop;

        wait for 100 ns;
        stop_sim <= true;
        wait;
    end process stim;

end architecture test;