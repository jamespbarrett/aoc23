library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity sel_tb is
end entity sel_tb;

architecture test of sel_tb is
    signal stop_sim : boolean := false;

    signal input : std_logic_vector(7 downto 0);

    component sel
        generic (
            N : integer := 1
        );
        port(
            A : in std_logic_vector(N - 1 downto 0);
            B : in std_logic_vector(N - 1 downto 0);
            S : in std_logic;
            Q : out std_logic_vector(N - 1 downto 0)
        );
    end component;

    signal A : std_logic_vector(1 downto 0);
    signal B : std_logic_vector(1 downto 0);
    signal S : std_logic;
    signal Q : std_logic_vector(1 downto 0);
    signal good : boolean;
begin

    UUT: sel 
        generic map (
            N => 2
        )
        port map (
            A => A,
            B => B,
            S => S,
            Q => Q
        );

    stim: process 
        variable data : std_logic_vector(4 downto 0);
    begin
        stop_sim <= false;
    
        for n in 0 to 31 loop
            data := std_logic_vector(to_unsigned(n, 5));

            A <= data(1 downto 0);
            B <= data(3 downto 2);
            S <= data(4);

            wait for 10 ns;

            good <= (data(1 downto 0) = Q) when data(4) = '0' else (data(3 downto 2) = Q);

            wait for 10 ns;
        end loop;

        wait for 100 ns;
        stop_sim <= true;
        wait;
    end process stim;

end architecture test;