library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity newline_tb is
end entity newline_tb;

architecture test of newline_tb is
    signal stop_sim : boolean := false;

    signal input : std_logic_vector(7 downto 0);

    component newline
        port(
            input : in  std_logic_vector(7 downto 0);
            is_newline : out std_logic
        );
    end component;

    signal is_newline : std_logic;
    signal good : boolean;
begin

    UUT: newline 
        port map (
            input => input,
            is_newline => is_newline
        );

    stim: process 
    begin
        stop_sim <= false;
        input <= (others => '0');
        good <= true;

        for i in 0 to 255 loop
            input <= std_logic_vector(to_unsigned(i, 8));

            wait for 10 ns;

            if ( i = 10) then
                good <= (is_newline = '1');
            else
                good <= (is_newline = '0');
            end if;
        end loop;

        wait for 100 ns;
        stop_sim <= true;
        wait;
    end process stim;

end architecture test;