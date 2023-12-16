library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BCD_add is
    port(
        A  : in  std_logic_vector(3 downto 0);
        B  : in  std_logic_vector(3 downto 0);
        CI : in  std_logic;
        O  : out std_logic_vector(3 downto 0);
        CO : out std_logic
    );
end entity BCD_add;

architecture rtl of BCD_add is
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

    signal BIN : std_logic_vector(4 downto 0);

    pure function BCDCONV(
        n : integer
    ) return std_logic_vector is
        variable rval : std_logic_vector(31 downto 0) := (others => '0');
        variable tmp : std_logic_vector(3 downto 0);
    begin
        for i in 19 downto 0 loop
            tmp := std_logic_vector(to_unsigned(i, 4)) when i < 10 else std_logic_vector(to_unsigned(i - 10, 4));
            rval(i) := tmp(n);
        end loop;
        
        return rval;
    end function;
begin

    ADD: addn
        generic map (
            N => 4
        )
        port map (
            A => A,
            B => B,
            CI => CI,
            O => BIN(3 downto 0),
            CO => BIN(4)
        );

    GEN: for i in 0 to 3 generate
        LUT: LUT1
            generic map(
                ILEN => 5,
                DATA => BCDCONV(i)
            )
            port map (
                input => BIN,
                output => O(i)
            );
    end generate;

    CO <= '1' when BIN(4) or (BIN(3) and (BIN(2) or BIN(1))) else '0';

end rtl;
