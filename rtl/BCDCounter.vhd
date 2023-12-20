library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BCDCounter is
    generic (
        DIGITS : integer;
        RSTVAL : std_logic_vector((4*DIGITS) - 1 downto 0) := (others => '0')
    );
    port(
        clock : in std_logic;
        reset : in std_logic;

        INC : in std_logic;
        Q : out std_logic_vector((4*DIGITS) - 1 downto 0)
    );
end entity BCDCounter;

architecture rtl of BCDCounter is
    
    pure function BCDADD1BIT(
        N: integer
    ) return std_logic_vector is
        variable rval: std_logic_vector(31 downto 0) := (others => '0');
        variable tmp: std_logic_vector(3 downto 0);
    begin
        for i in 0 to 9 loop
            tmp := std_logic_vector(to_unsigned(i, 4));
            rval(i) := tmp(n);
            tmp := std_logic_vector(to_unsigned((i + 1) mod 10, 4)) when i + 1 < 10 else x"0";
            rval(16 + i) := tmp(n);
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

    signal counter : std_logic_vector((4*DIGITS)-1 downto 0);
    signal C : std_logic_vector(DIGITS-1 downto 0);
    signal nextval : std_logic_vector((4*DIGITS)-1 downto 0);

begin

    LUTGEN0: for j in 3 downto 0 generate
        LUT0: LUT1
            generic map (
                ILEN => 4,
                DATA => BCDADD1BIT(j)(31 downto 16)
            )
            port map (
                input => counter(3 downto 0),
                output => nextval(j)
            );
    end generate;
        
    C(0) <= counter(3) and not counter(2) and not counter(1) and counter(0);

    DIGGEN: for i in DIGITS - 1 downto 1 generate
        LUTGEN: for j in 3 downto 0 generate
            LUT: LUT1
            generic map (
                ILEN => 5,
                DATA => BCDADD1BIT(j)
            )
            port map (
                input => C(i-1) & counter(4*i + 3 downto 4*i),
                output => nextval(4*i + j)
            );
        end generate;

        C(i) <= C(i-1) and counter(4*i + 3) and not counter(4*i + 2) and not counter(4*i + 1) and counter(4*i + 0);
    end generate;

    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '0' then
                counter <= RSTVAL;
            elsif INC = '1' then
                counter <= nextval;
            end if;
        end if;
    end process;

    Q <= counter;
end rtl;
