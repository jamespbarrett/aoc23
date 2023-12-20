library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BCDAccum is
    generic (
        DIGITS_IN : integer;
        DIGITS_EXTRA : integer
    );
    port(
        clock : in std_logic;
        reset : in std_logic;

        EN : in std_logic;
        I : in std_logic_vector((4*DIGITS_IN) - 1 downto 0);
        Q : out std_logic_vector((4*(DIGITS_IN + DIGITS_EXTRA)) - 1 downto 0)
    );
end entity BCDAccum;

architecture rtl of BCDAccum is
    
    pure function BCDADD1BIT(
        N: integer
    ) return std_logic_vector is
        variable rval: std_logic_vector(31 downto 0) := (others => '0');
        variable tmp: std_logic_vector(3 downto 0);
    begin
        for j in 0 to 9 loop
            tmp := std_logic_vector(to_unsigned(j, 4));
            rval(j) := tmp(n);
            tmp := std_logic_vector(to_unsigned((j + 1) mod 10, 4)) when j + 1 < 10 else x"0";
            rval(16 + j) := tmp(n);
        end loop;
        return rval;
    end function;

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

    component BCD_add
        port(
            A  : in  std_logic_vector(3 downto 0);
            B  : in  std_logic_vector(3 downto 0);
            CI : in  std_logic;
            O  : out std_logic_vector(3 downto 0);
            CO : out std_logic
        );
    end component;


    signal C : std_logic_vector(DIGITS_IN + DIGITS_EXTRA - 1 downto 0);

    signal nval : std_logic_vector(Q'range);
    signal ctr : std_logic_vector(Q'range);

begin

    ADD0 : BCD_add
        port map (
            A => I(3 downto 0),
            B => ctr(3 downto 0),
            CI => '0',
            O => nval(3 downto 0),
            CO => C(0)
        );

    GENADD: for n in 1 to DIGITS_IN - 1 generate
        ADD: BCD_add
            port map (
                A => I(4*n + 3 downto 4*n),
                B => ctr(4*n + 3 downto 4*n),
                CI => C(n - 1),
                O => nval(4*n + 3 downto 4*n),
                CO => C(n)
            );
    end generate;

    GENINC: for n in DIGITS_IN to (DIGITS_IN + DIGITS_EXTRA - 1) generate
        GENLUT: for j in 3 downto 0 generate
            LUT: LUT1
                generic map (
                    ILEN => 5,
                    DATA => BCDADD1BIT(j)
                )
                port map (
                    input => C(n-1) & ctr(4*n + 3 downto 4*n),
                    output => nval(4*n + j)
                );
        end generate;

        C(n) <= C(n-1) and ctr(4*n + 3) and ctr(4*n);
    end generate;

    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '0' then
                ctr <= (others => '0');
            elsif EN = '1' then
                ctr <= nval;
            end if;
        end if;
    end process;

    Q <= ctr;

end rtl;
