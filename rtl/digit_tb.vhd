library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity digit_tb is
end entity digit_tb;

architecture test of digit_tb is
    signal stop_sim : boolean := false;

    signal input : std_logic_vector(7 downto 0);

    component digit
        port(
            input : in  std_logic_vector(7 downto 0);
            is_digit : out std_logic
        );
    end component;

    signal is_digit : std_logic;
    signal good : boolean;
begin

    UUT: digit 
        port map (
            input => input,
            is_digit => is_digit
        );

    stim: process 
    begin
        stop_sim <= false;
        input <= (others => '0');
        good <= true;

        for i in 0 to 255 loop
            input <= std_logic_vector(to_unsigned(i, 8));

            wait for 10 ns;

            if ( i >= 48 and i <= 57) then
                good <= (is_digit = '1');
            else
                good <= (is_digit = '0');
            end if;
        end loop;

        wait for 100 ns;
        stop_sim <= true;
        wait;
    end process stim;

end architecture test;