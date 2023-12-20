library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BCDGT is
    generic (
        CMPVAL : integer range 0 to 9
    );
    port(
        I : in std_logic_vector(3 downto 0);
        Q : out std_logic
    );
end entity BCDGT;

architecture rtl of BCDGT is
    
    pure function BCDGTVAL(
        CMP : integer range 0 to 9
    ) return std_logic_vector is
        variable rval : std_logic_vector(15 downto 0) := (others => '0');
    begin
        for n in 0 to CMP loop
            rval(n) := '0';
        end loop;

        for n in CMP + 1 to 9 loop
            rval(n) := '1';
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
begin

    LUT: LUT1
    generic map (
        ILEN => 4,
        DATA => BCDGTVAL(CMPVAL)
    )
    port map (
        input => I,
        output => Q
    );
end rtl;
