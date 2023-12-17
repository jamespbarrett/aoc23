library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec is
    port(
        clock : std_logic;
        reset : std_logic;

        I : in std_logic_vector(7 downto 0);
        O : out std_logic_vector(3 downto 0);
        EN : out std_logic
    );
end entity dec;

architecture rtl of dec is
    component strdet
        generic (
            STR: string
        );
        port(
            clock : std_logic;
            reset : std_logic;
    
            I : in std_logic_vector(7 downto 0);
            Q : out std_logic
        );
    end component;

    signal Q : std_logic_vector(9 downto 1);
begin

    UUT1: strdet
        generic map (
            STR => "one"
        )
        port map (
            clock => clock,
            reset => reset,
            I => I,
            Q => Q(1)
        );
    UUT2: strdet
        generic map (
            STR => "two"
        )
        port map (
            clock => clock,
            reset => reset,
            I => I,
            Q => Q(2)
        );
    UUT3: strdet
        generic map (
            STR => "three"
        )
        port map (
            clock => clock,
            reset => reset,
            I => I,
            Q => Q(3)
        );
    UUT4: strdet
        generic map (
            STR => "four"
        )
        port map (
            clock => clock,
            reset => reset,
            I => I,
            Q => Q(4)
        );
    UUT5: strdet
        generic map (
            STR => "five"
        )
        port map (
            clock => clock,
            reset => reset,
            I => I,
            Q => Q(5)
        );
    UUT6: strdet
        generic map (
            STR => "six"
        )
        port map (
            clock => clock,
            reset => reset,
            I => I,
            Q => Q(6)
        );
    UUT7: strdet
        generic map (
            STR => "seven"
        )
        port map (
            clock => clock,
            reset => reset,
            I => I,
            Q => Q(7)
        );
    UUT8: strdet
        generic map (
            STR => "eight"
        )
        port map (
            clock => clock,
            reset => reset,
            I => I,
            Q => Q(8)
        );
    UUT9: strdet
        generic map (
            STR => "nine"
        )
        port map (
            clock => clock,
            reset => reset,
            I => I,
            Q => Q(9)
        );

    process(Q)
        variable tmp : std_logic_vector(3 downto 0);
        variable o_v : std_logic_vector(3 downto 0);
        variable en_v : std_logic;
    begin
        en_v := '0';
        o_v := x"0";
        for n in 1 to 9 loop
            en_v := en_v or Q(n);
            tmp := std_logic_vector(to_unsigned(n, 4));
            for x in 3 downto 0 loop
                if tmp(x) = '1' then
                    o_v(x) := o_v(x) or Q(n);
                end if;
            end loop;
        end loop;
        O <= o_v;
        EN <= en_v;
    end process;

end rtl;
