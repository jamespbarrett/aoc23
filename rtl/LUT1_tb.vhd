library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity LUT1_tb is
end entity LUT1_tb;

architecture test of LUT1_tb is
    signal stop_sim : boolean := false;

    signal input : std_logic_vector(3 downto 0);
    signal output : std_logic;

    component LUT1
        generic (
            ILEN: integer := 1;
            DATA : std_logic_vector((2 ** ILEN) - 1 downto 0)
        );
        port(
            input : in  std_logic_vector(ILEN - 1 downto 0);
            output : out std_logic
        );
    end component;

    signal good : boolean;
    constant DATA : std_logic_vector(15 downto 0) := x"CAFE";
begin

    UUT: LUT1 
        generic map (
            ILEN => 4,
            DATA => DATA
        )
        port map (
            input => input,
            output => output
        );

    stim: process 
    begin
        stop_sim <= false;
        input <= (others => '0');
        good <= true;

        for i in 0 to 15 loop
            input <= std_logic_vector(to_unsigned(i, 4));

            wait for 10 ns;

            good <= (output = DATA(i));
        end loop;

        wait for 100 ns;
        stop_sim <= true;
        wait;
    end process stim;

end architecture test;