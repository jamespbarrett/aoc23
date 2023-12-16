library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity add1_tb is
end entity add1_tb;

architecture test of add1_tb is
    signal stop_sim : boolean := false;

    component add1
        port(
            A  : in  std_logic;
            B  : in  std_logic;
            CI : in  std_logic;
            O  : out std_logic;
            CO : out std_logic
        );
    end component;

    signal A  : std_logic;
    signal B  : std_logic;
    signal CI : std_logic;

    signal O  : std_logic;
    signal CO : std_logic; 

    signal good : boolean;
begin

    UUT: add1 
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

        A  <= '0';
        B  <= '0';
        CI <= '0';

        wait for 10 ns;

        good <= (std_logic_vector'(CO & O) = std_logic_vector'("00"));

        wait for 10 ns;


        A  <= '1';
        B  <= '0';
        CI <= '0';

        wait for 10 ns;

        good <= (std_logic_vector'(CO & O) = std_logic_vector'("01"));

        wait for 10 ns;


        A  <= '0';
        B  <= '1';
        CI <= '0';

        wait for 10 ns;

        good <= (std_logic_vector'(CO & O) = std_logic_vector'("01"));

        wait for 10 ns;


        A  <= '1';
        B  <= '1';
        CI <= '0';

        wait for 10 ns;

        good <= (std_logic_vector'(CO & O) = std_logic_vector'("10"));

        wait for 10 ns;


        A  <= '0';
        B  <= '0';
        CI <= '1';

        wait for 10 ns;

        good <= (std_logic_vector'(CO & O) = std_logic_vector'("01"));

        wait for 10 ns;


        A  <= '1';
        B  <= '0';
        CI <= '1';

        wait for 10 ns;

        good <= (std_logic_vector'(CO & O) = std_logic_vector'("10"));

        wait for 10 ns;


        A  <= '1';
        B  <= '1';
        CI <= '1';

        wait for 10 ns;

        good <= (std_logic_vector'(CO & O) = std_logic_vector'("11"));

        wait for 10 ns;

        wait for 100 ns;
        stop_sim <= true;
        wait;
    end process stim;

end architecture test;