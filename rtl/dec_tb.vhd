library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity dec_tb is
end entity dec_tb;

architecture test of dec_tb is
    signal stop_sim : boolean := false;

    signal clock : std_logic;
    signal reset : std_logic;

    signal I : std_logic_vector(7 downto 0);
    signal O : std_logic_vector(3 downto 0);
    signal EN : std_logic;

    component dec
        port(
            clock : std_logic;
            reset : std_logic;
    
            I : in std_logic_vector(7 downto 0);
            O : out std_logic_vector(3 downto 0);
            EN : out std_logic
        );
    end component;

    signal good : boolean;
begin

    UUTA: dec
        port map (
            clock => clock,
            reset => reset,

            I => I,
            O => O,
            EN => EN
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

            good <= (EN = '1' and O = x"1") when (n = 16) else (EN = '0');
        end loop;

        wait for 100 ns;
        stop_sim <= true;
        wait;
    end process stim;

end architecture test;