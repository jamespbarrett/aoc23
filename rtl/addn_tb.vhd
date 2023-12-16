library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity addn_tb is
end entity addn_tb;

architecture test of addn_tb is
    signal stop_sim : boolean := false;

    component addn
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
    end component;

    signal A  : std_logic_vector(3 downto 0);
    signal B  : std_logic_vector(3 downto 0);
    signal CI : std_logic;

    signal O  : std_logic_vector(3 downto 0);
    signal CO : std_logic; 

    signal good : boolean;
begin

    UUT: addn 
        port map (
            A => A,
            B => B,
            CI => CI,
            O => O,
            CO => CO
        );

    stim: process 
    begin
        stop_sim <= false;
        good <= true;

        for i in 0 to 15 loop
            A <= std_logic_vector(to_unsigned(i, 4));
            for j in 0 to 15 loop
                B <= std_logic_vector(to_unsigned(j, 4));
                CI <= '0';

                wait for 10 ns;

                good <= ((CO & O) = std_logic_vector(to_unsigned(i + j, 5)));

                wait for 10 ns;

                CI <= '1';

                wait for 10 ns;

                good <= ((CO & O) = std_logic_vector(to_unsigned(i + j + 1, 5)));

                wait for 10 ns;
            end loop;
        end loop;

        wait for 100 ns;
        stop_sim <= true;
        wait;
    end process stim;

end architecture test;