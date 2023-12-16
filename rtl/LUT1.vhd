library ieee;
use ieee.std_logic_1164.all;

entity LUT1 is
    generic (
        ILEN: integer := 1;
        DATA : std_logic_vector((2 ** ILEN) - 1 downto 0)
    );
    port(
        input : in std_logic_vector(ILEN - 1 downto 0);
        output : out std_logic
    );
end entity LUT1;

architecture rtl of LUT1 is
    signal A: std_logic;
    signal B: std_logic;

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
begin
    GEN1: if ILEN = 1 generate
        A <= DATA(0);
        B <= DATA(1);
    end generate;

    GENN: if ILEN > 1 generate
        LUTA: LUT1
            generic map (
                ILEN => ILEN - 1,
                DATA => DATA((2 ** (ILEN - 1)) - 1 downto 0)
            )
            port map (
                input => input(ILEN - 2 downto 0),
                output => A
            );

        LUTB: LUT1
            generic map (
                ILEN => ILEN - 1,
                DATA => DATA((2** ILEN) - 1 downto (2 ** (ILEN - 1)))
            )
            port map (
                input => input(ILEN - 2 downto 0),
                output => B
            );
    end generate;

    SEL_I: sel 
        generic map (
            N => 1
        )
        port map (
            A(0) => A,
            B(0) => B,
            S => input(ILEN - 1),
            Q(0) => output
        );
end rtl;
