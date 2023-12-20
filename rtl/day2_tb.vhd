library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity day2_tb is
end entity day2_tb;

architecture test of day2_tb is
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';

    signal stop_sim : boolean := false;

    signal input : std_logic_vector(7 downto 0);

    signal input_char : character;

    signal output : std_logic_vector(7 downto 0);
    signal output_char : character;

    component day2
        port(
            clock : in std_logic;
            reset : in  std_logic;
            input : in  std_logic_vector(7 downto 0);
            output : out std_logic_vector(7 downto 0)
        );
    end component;
begin

    UUT: day2 
        port map (
            clock => clock,
            reset => reset,
            input => input,
            output => output
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
        file romfile : text open read_mode is "input/day2.txt";
        variable row : line;
        variable data: character;
        variable good: boolean;
    begin
        stop_sim <= false;
        reset <= '0';
        input <= (others => 'U');

        wait for 17 ns;

        reset <= '1';
        input <= (others => '0');

        wait until falling_edge(clock);

        while (not endfile(romfile)) loop
            readline(romfile, row);
            
            good := true;
            while (good) loop
                read(row, data, good);
                if(good) then
                    wait until falling_edge(clock);
                    input_char <= data;
                    input <= std_logic_vector(to_unsigned(character'pos(data), 8));
                end if;
            end loop;
            
            wait until falling_edge(clock);
            input_char <= LF;
            input <= std_logic_vector(to_unsigned(character'pos(LF), 8));
        end loop;

        wait until falling_edge(clock);
        input_char <= nul;
        input <= (others => '0');

        wait for 100 ns;
        stop_sim <= true;
        wait;
    end process stim;

    output_char <= character'val(to_integer(unsigned(output)));

end architecture test;